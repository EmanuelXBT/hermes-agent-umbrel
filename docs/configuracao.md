# ⚙️ Configuração — Referência Completa

> Toda configuração do Hermes Agent no Umbrel. Atualizado para versão 0.19+.

---

## Arquivos de configuração

| Arquivo | Propósito | Contém segredos? |
|---|---|---|
| `/opt/data/config.yaml` | Comportamento: modelos, plataformas, tools, agent | Não (referencia `.env`) |
| `/opt/data/.env` | API keys, tokens, credenciais | **Sim** — nunca commitado |
| `/opt/data/SOUL.md` | Personalidade: tom, regras, identidade | Não |

---

## `config.yaml` — Estrutura completa

```yaml
# ── Modelo ──────────────────────────────────────────
model:
  default: "openrouter/owl-alpha"       # Modelo principal
  provider: "openrouter"                 # Provedor padrão
  # context_length: 131072               # Opcional: override do limite

# ── Agente ──────────────────────────────────────────
agent:
  max_turns: 90                          # Máximo de iterações por resposta
  tool_use_enforcement: true             # Força uso de ferramentas

# ── Terminal ────────────────────────────────────────
terminal:
  timeout: 180                           # Timeout de comandos (segundos)
  # backend: local                       # Padrão: executa no container

# ── Gateway (mensageria) ────────────────────────────
gateway:
  platforms:
    telegram:
      enabled: true
      bot_token: "${TELEGRAM_BOT_TOKEN}"   # Lê do .env
      # allowed_chats: [123456789]          # Opcional: whitelist de user IDs

    whatsapp:
      enabled: false
      # Configuração gerenciada pelo plugin

# ── Aprovações ──────────────────────────────────────
approvals:
  mode: manual        # manual | smart | off
  # mode: smart       # Auto-aprova baixo risco
  # mode: off         # ⚠️ Sem confirmação

# ── Segurança ───────────────────────────────────────
security:
  redact_secrets: true             # Remove secrets do contexto
  # tirith_enabled: true           # Scanner de segurança (padrão: on)

# ── Compressão de contexto ──────────────────────────
compression:
  enabled: true
  threshold: 0.50                  # % de uso do contexto que dispara compressão
  target_ratio: 0.20               # % do contexto a manter após compressão

# ── Memória ─────────────────────────────────────────
memory:
  memory_enabled: true             # Memória persistente entre sessões
  user_profile_enabled: true       # Perfil do usuário (nome, preferências)
  provider: "builtin"              # builtin | honcho | mem0

# ── Delegação (subagentes) ──────────────────────────
delegation:
  max_concurrent_children: 3       # Subagentes paralelos
  max_spawn_depth: 1               # Profundidade de nesting
  max_iterations: 50               # Iterações máximas por subagente

# ── Cron ────────────────────────────────────────────
cron:
  enabled: true
  # mirror_delivery: false         # Entrega de output em chat ativo

# ── Curator (gestão de skills) ──────────────────────
curator:
  enabled: true
  interval_hours: 24               # Frequência de verificação
  min_idle_hours: 72               # Skills inativas por X horas → stale
  stale_after_days: 30             # Stale por X dias → archive
```

---

## `.env` — Variáveis de ambiente

```env
# Provedores de IA (configure pelo menos um)
OPENROUTER_API_KEY=sk-or-v1-...
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...
DEEPSEEK_API_KEY=sk-...

# Mensageria
TELEGRAM_BOT_TOKEN=123456789:AAH...

# GitHub (para integração com repositórios)
GITHUB_TOKEN=ghp_...

# Outros serviços (opcionais)
NOTION_API_KEY=...
SPOTIFY_CLIENT_ID=...
SPOTIFY_CLIENT_SECRET=...
```

As variáveis podem ser referenciadas no `config.yaml` com `${VARIAVEL}`.

---

## `SOUL.md` — Personalidade

O SOUL é injetado no system prompt de **toda** conversa. Define tom, regras, identidade.

```markdown
# SOUL — Assistente Pessoal

## Quem você é
Assistente técnico de um desenvolvedor. Direto, prático, sem firulas.

## Tom e estilo
- Português brasileiro (primário)
- Respostas curtas e objetivas
- Prefere código funcional a explicações longas
- Admite quando não sabe — sem alucinar

## Regras
- Não executa comandos destrutivos sem confirmação
- Arquivos duráveis vão em /opt/data
- Sempre propõe a solução mais simples primeiro
```

### Variáveis disponíveis no SOUL

O Hermes injeta automaticamente informações do ambiente no system prompt. Você **não** precisa incluir:

- Sistema operacional e host
- Paths padrão (`$HOME`, `/opt/data`)
- Versão do Python
- Plataformas conectadas

Isso tudo é adicionado automaticamente pelo `prompt_builder`.

---

## Skills

Skills expandem as capacidades do agente. São documentos Markdown com instruções que o agente carrega quando relevantes.

### Gerenciamento

```bash
# Listar skills instaladas
hermes skills list

# Buscar no catálogo
hermes skills search "github"

# Instalar
hermes skills install github-workflow

# Remover
hermes skills uninstall github-workflow

# Ver detalhes de uma skill
hermes skills inspect github-workflow
```

### Skills recomendadas para Umbrel

| Skill | Categoria | Função |
|---|---|---|
| `umbrel` | DevOps | Gerenciar apps, containers, persistência no Umbrel |
| `github-workflow` | Desenvolvimento | PRs, issues, code review, CI/CD |
| `obsidian-vault-workflows` | Notas | Criar e gerenciar notas no Obsidian |
| `dev-workflow` | Desenvolvimento | TDD, debugging, code review |
| `hermes-desktop-umbrel` | Infra | Conectar Hermes Desktop ao Umbrel |
| `media` | Mídia | YouTube, GIFs, playlists |
| `research` | Pesquisa | arXiv, papers, RSS |
| `productivity` | Produtividade | Google Workspace, Notion, Airtable |

### Skills auto-criadas

O Hermes cria skills automaticamente quando aprende workflows novos. Elas ficam em `/opt/data/skills/` com `created_by: "agent"`. O **Curator** gerencia o ciclo de vida delas (ativa → idle → stale → archive).

---

## Profiles (múltiplos usuários/contextos)

Se mais de uma pessoa usa o mesmo Umbrel, ou você quer separar contextos (trabalho vs pessoal):

```bash
# Criar perfil
hermes profile create trabalho

# Listar perfis
hermes profile list

# Usar perfil específico
hermes --profile trabalho

# Cada perfil tem skills/, memories/, plugins/ isolados
```

---

## Modelos de IA recomendados

| Modelo | Provedor | Custo | Ideal para |
|---|---|---|---|
| `google/gemini-2.5-flash` | OpenRouter | **Grátis** | Tarefas diárias, teste |
| `google/gemini-2.5-pro` | OpenRouter | Baixo | Tarefas complexas |
| `anthropic/claude-sonnet-4` | OpenRouter | Médio | Código, raciocínio |
| `deepseek/deepseek-chat` | DeepSeek | Muito baixo | Alternativa barata |
| `openai/gpt-4o` | OpenAI | Alto | Qualidade máxima |

Para tarefas que exigem raciocínio visual (análise de imagens), use modelos com suporte a visão como `google/gemini-2.5-flash` ou `openai/gpt-4o`.

---

## Próximo passo

- [`dispositivos.md`](dispositivos.md) — Conectar celular, notebook e outros
- [`manutencao.md`](manutencao.md) — Limpeza, backup, troubleshooting
