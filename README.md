# 🏠 Hermes Agent no Umbrel — Guia Definitivo

> **Tenha um agente de IA autônomo 24/7 no seu Umbrel, acessível de qualquer dispositivo.**
>
> Instalação · Configuração · Multi-dispositivo · Manutenção

[![Hermes](https://img.shields.io/badge/Hermes-Agent-6c5ce7?logo=robot)](https://github.com/NousResearch/hermes-agent)
[![Umbrel](https://img.shields.io/badge/Platform-Umbrel_OS-f59e0b)](https://umbrel.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## O que é?

O **Hermes Agent** é um assistente de IA open-source da [Nous Research](https://nousresearch.com) que roda no terminal, messaging apps e IDEs. Instalado no **Umbrel OS** como um app, ele se torna um agente **24/7** — sempre online, acessível via Telegram, WhatsApp, Discord e outros mensageiros direto do seu celular ou computador.

### Por que no Umbrel?

| Sem Umbrel | Com Umbrel |
|---|---|
| Roda só quando o PC está ligado | **24/7** — sempre online |
| Acesso só pelo terminal | **Celular, notebook, qualquer dispositivo** |
| Dados locais, sem backup | **Persistência** em `/opt/data`, backups automáticos |
| Instalação manual complexa | **App Store** — um clique |

### Arquitetura em 30 segundos

```
📱 Seu celular          🖥️ Seu MacBook/PC         🌐 APIs de IA
      │                       │                       │
      ▼                       ▼                       ▼
  Telegram/WhatsApp    Hermes Desktop (SSH)    OpenRouter/Anthropic
      │                       │                       │
      └───────────────────────┼───────────────────────┘
                              │
                     ┌────────▼────────┐
                     │   Umbrel OS     │
                     │  ┌────────────┐ │
                     │  │   Hermes   │ │
                     │  │   Agent    │ │
                     │  └────────────┘ │
                     │  /opt/data (2TB)│
                     └─────────────────┘
```

Tudo converge no Umbrel. Ele é o cérebro que nunca dorme.

---

## 📋 Índice

- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Conectando dispositivos](#-conectando-dispositivos)
- [Configuração](#-configuração)
- [Manutenção](#-manutenção)
- [Troubleshooting](#-troubleshooting)
- [Estrutura de arquivos](#-estrutura-de-arquivos)
- [Leitura adicional](#-leitura-adicional)

---

## 📦 Pré-requisitos

| Requisito | Onde conseguir |
|---|---|
| Umbrel Home ou Umbrel OS | [umbrel.com](https://umbrel.com) |
| API key de provedor de IA | [OpenRouter](https://openrouter.ai/keys) (recomendado) ou [Anthropic](https://console.anthropic.com), [OpenAI](https://platform.openai.com) |
| Bot do Telegram (opcional) | [@BotFather](https://t.me/BotFather) |
| Node.js 18+ (só se for usar WhatsApp) | [nodejs.org](https://nodejs.org) |

---

## 🚀 Instalação

### 1. Instalar o app no Umbrel

1. Acesse o dashboard do Umbrel (`http://umbrel.local` ou IP local)
2. **App Store** → busque **Hermes Agent**
3. Clique em **Install** (~600 MB, depende da conexão)

O app cria automaticamente dois containers Docker que compartilham `/opt/data`:

| Container | Função |
|---|---|
| `web` | Dashboard web, terminal, proxy interno |
| `gateway` | Gateway de mensagens (WebSocket + polling) |

### 2. Configurar API Key

1. No dashboard do Umbrel, abra o app **Hermes Agent** → **Settings**
2. Selecione o provedor (ex: `openrouter`)
3. Cole sua API key
4. Salve e reinicie o gateway

> 💡 **Recomendação:** OpenRouter dá acesso a 100+ modelos com uma única key. Comece com `google/gemini-2.5-flash` (grátis) para testar.

### 3. Verificar

```bash
# Containers rodando?
docker ps | grep hermes

# Logs do gateway
tail -f /opt/data/logs/gateway.log
```

> ⚠️ **NUNCA execute `hermes update` manualmente.** Atualizações são gerenciadas pelo Umbrel OS via Docker images. Atualizar manualmente quebra o container.

---

## 📱 Conectando dispositivos

Esta é a parte que transforma o Hermes de "agente de terminal" em "assistente onipresente".

### Telegram (essencial)

1. Converse com [@BotFather](https://t.me/BotFather)
2. `/newbot` → escolha nome e username
3. **Copie o token** (formato: `123456789:ABCdef...`)
4. No `config.yaml` ou via dashboard Settings, configure o token
5. Reinicie o gateway
6. Envie `/start` para seu bot no Telegram

**Proteja o bot (recomendado):**

```yaml
# Restrinja acesso ao seu user ID pessoal
telegram:
  bot_token: "SEU_TOKEN"
  allowed_chats:
    - SEU_USER_ID         # Descubra com @userinfobot
```

### WhatsApp (via Baileys)

O Hermes suporta WhatsApp usando [Baileys](https://github.com/WhiskeySockets/Baileys) — uma implementação do protocolo WA Web que não requer servidor externo.

```bash
# O gateway gerencia a conexão via plugin WhatsApp
# Escaneie o QR code pelo app WhatsApp > Linked Devices
```

### MacBook / Desktop (via Hermes Desktop)

Para usar o Hermes diretamente do terminal do seu computador:

```
MacBook ──SSH tunnel──▶ Umbrel ──▶ Hermes Agent
      (hermes desktop)      (porta interna 18789)
```

Veja o guia completo em [`docs/dispositivos.md`](docs/dispositivos.md).

### Múltiplas plataformas simultâneas

O gateway gerencia todas as plataformas ao mesmo tempo. Você pode:

- Mandar mensagem pelo Telegram
- Receber resposta no WhatsApp
- Executar comandos pelo terminal SSH do MacBook
- Tudo compartilhando a mesma sessão e memória

---

## ⚙️ Configuração

### Estrutura dos arquivos

A configuração do Hermes no Umbrel usa dois arquivos principais:

| Arquivo | O que contém | Exemplo |
|---|---|---|
| `/opt/data/config.yaml` | Configuração declarativa (modelos, plataformas, tools) | `model.default: "openrouter/owl-alpha"` |
| `/opt/data/.env` | Segredos (API keys, tokens) | `OPENROUTER_API_KEY=sk-or-...` |

> ⚠️ `.env` nunca deve ser commitado. Contém chaves em texto puro.

### Configuração mínima (`config.yaml`)

```yaml
model:
  default: "openrouter/owl-alpha"   # Modelo padrão (grátis no OpenRouter)

gateway:
  platforms:
    telegram:
      enabled: true
      bot_token: "${TELEGRAM_BOT_TOKEN}"   # Lê do .env
      allowed_chats: []                     # Opcional: restrinja user IDs

approvals:
  mode: manual    # manual | smart | off
```

### Provedores de IA

| Provedor | Modelo gratuito | Setup |
|---|---|---|
| **OpenRouter** | `google/gemini-2.5-flash` | `OPENROUTER_API_KEY` no `.env` |
| **Anthropic** | — (pago) | `ANTHROPIC_API_KEY` no `.env` |
| **OpenAI** | — (pago) | `OPENAI_API_KEY` no `.env` |
| **Google AI** | `gemini-2.5-flash` | `GOOGLE_API_KEY` no `.env` |
| **DeepSeek** | — (barato) | `DEEPSEEK_API_KEY` no `.env` |

### SOUL — Personalidade do agente

Crie `/opt/data/SOUL.md` para definir como o agente se comporta:

```markdown
# SOUL — Assistente Pessoal

Você é um assistente técnico direto e prático.
Responde em português brasileiro.
Vai direto ao ponto — sem enrolação.
```

O SOUL é carregado no system prompt de toda conversa.

### Skills — Expansão de capacidades

Skills são módulos que ensinam o Hermes a executar tarefas específicas. Eles são **auto-carregados** quando relevantes para a conversa.

```bash
# Listar skills instaladas
hermes skills list

# Instalar uma skill
hermes skills install nome-da-skill

# Ver catálogo
hermes skills browse
```

Skills essenciais para Umbrel:

| Skill | Função |
|---|---|
| `umbrel` | Gerenciar apps, containers, persistência |
| `github-workflow` | Criar PRs, issues, code review |
| `obsidian-vault-workflows` | Gerenciar notas no Obsidian |

### Segurança: Approval Modes

O Hermes pede confirmação antes de executar comandos perigosos. Três modos:

```yaml
approvals:
  mode: manual   # Pede confirmação para todo comando de risco (padrão)
  # mode: smart  # Auto-aprova comandos de baixo risco, pergunta nos de alto
  # mode: off    # Sem confirmação (⚠️ apenas em ambientes 100% confiáveis)
```

**Nunca use `mode: off` em produção.** O modo `smart` é um bom meio-termo.

Veja [`docs/configuracao.md`](docs/configuracao.md) para o guia completo de configuração.

---

## 🔧 Manutenção

### Limpeza periódica

```bash
# Script automatizado (recomendado)
bash scripts/cleanup.sh

# Ou manualmente
rm -rf /opt/data/.cache/uv/
rm -rf /opt/data/.npm/
find /opt/data -name "__pycache__" -type d -exec rm -rf {} +
```

### O que NUNCA remover

| Arquivo/Pasta | Por quê |
|---|---|
| `.env` | API keys — sem ele o agente para |
| `state.db` | Histórico de sessões + memória |
| `skills/` | Skills instaladas |
| `memories/` | Memórias de longo prazo do agente |
| `config.yaml` | Configuração principal |

### Backup

```bash
# Backup essencial (config + memórias)
tar -czf hermes-backup-$(date +%Y%m%d).tar.gz \
  /opt/data/config.yaml \
  /opt/data/.env \
  /opt/data/SOUL.md \
  /opt/data/skills/ \
  /opt/data/memories/
```

### Monitoramento

```bash
# Status do gateway
ps aux | grep hermes

# Logs em tempo real
tail -f /opt/data/logs/gateway.log

# Uso de recursos
df -h /opt/data
du -sh /opt/data/*/ | sort -rh | head -10
```

---

## 🔍 Troubleshooting

| Sintoma | Causa provável | Solução |
|---|---|---|
| Bot não responde no Telegram | Gateway offline ou token errado | `docker ps \| grep hermes`, verificar logs |
| "Resource not accessible" ao criar repo | Token GitHub sem scope `repo` | `gh auth refresh -s repo` |
| Container não inicia após update | Config incompatível com nova versão | Restaurar backup do `config.yaml` |
| Config perdida após reinício | Arquivo fora de `/opt/data` | **Tudo** durável deve estar em `/opt/data` |
| Sem espaço em disco | Acúmulo de cache/logs | Executar `cleanup.sh` |
| Gateway morre sozinho | Crash loop | `docker logs hermes-gateway --tail 50` |
| WhatsApp desconecta | Sessão expirada | Reescanear QR code |
| Erro 403 nas APIs | API key sem crédito ou inválida | Verificar saldo/créditos no provedor |

### Problemas específicos do Umbrel

**Gateway crash loop:** Reinicie o estado:
```bash
docker restart hermes-gateway
```

**DNS não resolve `umbrel.local`:** Use o IP local. Descubra com:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

**App não aparece na App Store:** Verifique se o Umbrel OS está atualizado (Settings → Update).

---

## 📁 Estrutura de arquivos

```
/opt/data/                    ← Persistente (sobrevive a updates)
├── config.yaml               ← Configuração principal
├── .env                      ← API keys e tokens (⚠️ nunca commitado)
├── SOUL.md                   ← Personalidade do agente
├── state.db                  ← Banco SQLite do gateway
├── skills/                   ← Skills instaladas
├── memories/                 ← Memórias de longo prazo (MEMORY.md + USER.md)
├── sessions/                 ← Histórico de conversas (.jsonl)
├── logs/                     ← Logs do gateway
├── .cache/                   ← Cache (pode ser removido)
├── .local/                   ← Pacotes Python locais
├── image_cache/              ← Imagens recebidas via messaging
├── audio_cache/              ← Áudios recebidos via messaging
└── obsidian-vault/           ← Vault Obsidian (se configurado)
```

---

## 📚 Leitura adicional

| Documento | Conteúdo |
|---|---|
| [`docs/dispositivos.md`](docs/dispositivos.md) | Guia completo de conexão multi-dispositivo |
| [`docs/configuracao.md`](docs/configuracao.md) | Referência completa de configuração |
| [`docs/arquitetura.md`](docs/arquitetura.md) | Diagrama de arquitetura e fluxo de dados |
| [`docs/manutencao.md`](docs/manutencao.md) | Rotinas de manutenção avançada |
| [Hermes Docs](https://hermes-agent.nousresearch.com/docs) | Documentação oficial |

---

## 📄 Licença

MIT — use, modifique, compartilhe.

---

> **Dica:** Depois de instalar, peça ao Hermes: *"Me mostre um resumo da sua configuração atual e sugira melhorias."*
