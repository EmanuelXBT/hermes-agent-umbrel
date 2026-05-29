# Configuração Avançada — Hermes Agent

## Arquivo config.yaml

Toda a configuração fica em `/opt/data/config.yaml`.

### Estrutura completa

```yaml
# Provedor de API
api:
  provider: "openrouter"          # openrouter, openai, anthropic
  key: "sk-or-sua-key"

# Telegram
telegram:
  bot_token: "SEU_TOKEN"
  allowed_chats:
    - 1410863491                  # Seu user ID

# Modelo de IA (opcional — usa padrão do provedor)
model:
  provider: "openrouter"
  name: "openrouter/owl-alpha"

# Skills (opcional)
skills:
  - "hermes-agent"
  - "umbrel"
```

## Provedores de API

| Provedor | Custo | Modelos | Nota |
|---|---|---|---|
| OpenRouter | Pay-as-you-use | 100+ modelos | ✅ Recomendado |
| OpenAI | Pay-as-you-use | GPT-4, GPT-4o | Caro |
| Anthropic | Pay-as-you-use | Claude 3.5 | Bom |
| Google AI | Free tier | Gemini | Limitado |

## SOUL.md — Personalidade

Crie `/opt/data/SOUL.md` para definir a personalidade:

```markdown
# SOUL.md

Você é um assistente técnico direto e prático.
Responde em português brasileiro.
Sem enrolação, vai direto ao ponto.
```

## Skills

Skills são módulos que expandem as capacidades do Hermes.

### Instalar skill

```bash
# Via terminal do Hermes
hermes skills install nome-da-skill
```

### Skills úteis

| Skill | Função |
|---|---|
| `umbrel` | Gerenciar apps do Umbrel |
| `github` | Gerenciar repositórios |
| `spotify` | Controlar Spotify |
| `youtube` | Transcrever vídeos |

## Variáveis de ambiente

Arquivo `/opt/data/.env`:

```env
OPENROUTER_API_KEY=sk-or-sua-key
TELEGRAM_BOT_TOKEN=seu-token
```

> ⚠️ Nunca commite `.env` no GitHub. Use `.gitignore`.
