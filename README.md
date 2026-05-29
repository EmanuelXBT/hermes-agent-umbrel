# 🤖 Hermes Agent no Umbrel — Guia Completo

> Guia prático de instalação, configuração e manutenção
> do Hermes Agent em ambiente Umbrel OS.

![Hermes](https://img.shields.io/badge/Hermes-Agent-blue)
![Umbrel](https://img.shields.io/badge/Platform-Umbrel_OS-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Stack](#-stack)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Conexão Telegram](#-conexão-telegram)
- [Manutenção](#-manutenção)
- [Troubleshooting](#-troubleshooting)
- [Estrutura de Pastas](#-estrutura-de-pastas)
- [Autor](#-autor)

---

## 🔭 Visão Geral

O **Hermes Agent** é um assistente de IA open-source desenvolvido pela
[Nous Research](https://nousresearch.com). Rodando no **Umbrel OS**,
ele se torna um agente autônomo acessível via Telegram, capaz de:

- Executar comandos no terminal
- Navegar na web
- Gerenciar arquivos
- Monitorar serviços
- Automatizar tarefas via cron jobs
- Expandir funcionalidades com skills

Este guia documenta todo o processo de instalação, configuração e
manutenção em ambiente Umbrel.

---

## 🛠 Stack

| Camada | Tecnologia |
|---|---|
| **SO** | Umbrel OS (Linux containerizado) |
| **Agente** | Hermes Agent (Nous Research) |
| **API** | OpenRouter / OpenAI / Anthropic |
| **Mensageria** | Telegram Bot API |
| **Persistência** | SQLite + filesystem (`/opt/data`) |

---

## 📦 Pré-requisitos

- [ ] Umbrel Home ou Umbrel OS instalado e acessível
- [ ] Conta no [Umbrel App Store](http://umbrel.local)
- [ ] Conta em provedor de API (recomendado: [OpenRouter](https://openrouter.ai))
- [ ] API Key do provedor escolhido
- [ ] Bot criado no Telegram via [@BotFather](https://t.me/BotFather)

---

## 🚀 Instalação

### Via Umbrel App Store

1. Acesse `http://umbrel.local` (ou IP do seu Umbrel)
2. Navegue até **App Store**
3. Busque por **"Hermes Agent"**
4. Clique em **Install**
5. Aguarde o download (~600MB)

### Pós-instalação

Após instalar, o app cria dois containers que compartilham `/opt/data`:

| Container | Função |
|---|---|
| `web` | Dashboard, terminal, proxy |
| `gateway` | Gateway de mensagens (WebSocket) |

> ⚠️ **Importante:** Não execute `hermes update` manualmente.
> Atualizações são gerenciadas pelo Umbrel OS via Docker images.

---

## ⚙️ Configuração

### API Key

1. Acesse o app Hermes no dashboard do Umbrel
2. Vá em **Settings**
3. Defina o provedor de API (ex: `openrouter`)
4. Cole sua API Key
5. Salve e reinicie o gateway

### Arquivo de configuração

O arquivo principal é `/opt/data/config.yaml`:

```yaml
# Exemplo de configuração mínima
telegram:
  bot_token: "SEU_BOT_TOKEN"

api:
  provider: "openrouter"
  key: "sua-api-key-aqui"
```

---

## 📱 Conexão Telegram

### 1. Criar o bot

1. Abra o Telegram e converse com [@BotFather](https://t.me/BotFather)
2. Envie `/newbot`
3. Defina um nome (ex: `Meu Hermes`)
4. Defina um username (ex: `meu_hermes_bot`)
5. **Copie o token** fornecido

### 2. Configurar no Hermes

Adicione ao `config.yaml`:

```yaml
telegram:
  bot_token: "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
```

### 3. Testar

1. Reinicie o gateway
2. Abra o Telegram e envie `/start` para o bot
3. O bot deve responder com uma mensagem de boas-vindas

### 4. Whitelist (opcional, recomendado)

Restrinja o acesso ao seu user ID:

```yaml
telegram:
  bot_token: "SEU_TOKEN"
  allowed_chats:
    - 1410863491
```

> ⚠️ Após alterar `allowed_chats`, é necessário reiniciar o gateway.

---

## 🔧 Manutenção

### Limpeza de cache

```bash
# Ver tamanho atual
du -sh /opt/data/

# Limpar cache do gerenciador de pacotes
rm -rf /opt/data/.cache/uv/

# Limpar cache npm
rm -rf /opt/data/.npm/

# Limpar backups antigos de config
rm -f /opt/data/config.yaml.bak.*

# Limpar __pycache__
find /opt/data -name "__pycache__" -type d -exec rm -rf {} +
```

### Verificar saúde do gateway

```bash
# Verificar se o processo está rodando
ps aux | grep hermes

# Ver logs
tail -f /opt/data/logs/gateway.log
```

### Backup

```bash
# Backup da configuração
cp /opt/data/config.yaml /opt/data/config.yaml.backup

# Backup completo do /opt/data
tar -czf /opt/data-backup-$(date +%Y%m%d).tar.gz /opt/data/
```

---

## 🔍 Troubleshooting

| Problema | Solução |
|---|---|
| Bot não responde | Verificar token, reiniciar gateway |
| Erro de API Key | Verificar se a key está válida e com crédito |
| Container não inicia | Verificar logs: `docker logs hermes-gateway` |
| Perdeu config após update | Config deve estar em `/opt/data/config.yaml` |
| `allowed_chats` não funciona | Reiniciar gateway após alterar |
| Sem espaço em disco | Executar limpeza de cache (seção acima) |

---

## 📁 Estrutura de Pastas

```
/opt/data/
├── config.yaml          # Configuração principal
├── .env                 # Variáveis de ambiente (API keys)
├── .skills_prompt_snapshot.json
├── state.db             # Banco SQLite do gateway
├── SOUL.md              # Personalidade customizada
├── skills/              # Skills instaladas
├── sessions/            # Histórico de sessões
├── memories/            # Memórias de longo prazo
│   ├── MEMORY.md
│   └── USER.md
├── logs/                # Logs do sistema
├── .cache/              # Cache (descartável)
├── .local/              # Pacotes Python (workaround venv)
└── github/              # Seus repositórios
    └── hermes-agent-umbrel/
```

---

## 👤 Autor

**Emanuel** — Técnico em Desenvolvimento de Sistemas @SENAC
Belo Horizonte, MG

- 🎓 Learn by doing: self-hosted AI, DevOps, automations
- 📫 Telegram: [@emanuelxbt](https://t.me/emanuelxbt)
- 💻 LinkedIn: linkedin.com/in/emanuelxbt  
- 💼 Buscando: Oportunidades de estágio ou primeiro emprego

---

## 📄 Licença

MIT — use, modifique e compartilhe à vontade.
