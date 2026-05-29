# Dicas e Skills Úteis — Hermes Agent

## Comandos úteis no chat

| Comando | O que faz |
|---|---|
| `/start` | Inicia conversa |
| `/help` | Lista comandos |
| `/new` | Nova sessão (limpa contexto) |
| `/stop` | Para execução atual |

## Skills recomendadas

### Para desenvolvimento

| Skill | Uso |
|---|---|
| `github` | Criar PRs, issues, code review |
| `github-pr-workflow` | Workflow completo de PR |
| `systematic-debugging` | Debug em 4 fases |
| `test-driven-development` | TDD |

### Para DevOps

| Skill | Uso |
|---|---|
| `umbrel` | Gerenciar apps Umbrel |
| `webhook-subscriptions` | Automatizar com webhooks |
| `docker` | Gerenciar containers |

### Para produtividade

| Skill | Uso |
|---|---|
| `notion` | Gerenciar Notion |
| `google-workspace` | Gmail, Calendar, Drive |
| `youtube-content` | Transcrever vídeos |

## Customizando a personalidade

Edite `/opt/data/SOUL.md`:

```markdown
# SOUL.md

Você é OWL, um assistente técnico brasileiro.
- Responde em português
- Direto ao ponto, sem enrolação
- Focado em soluções práticas
- Usa analogias quando ajuda
```

## Cron Jobs — Automação

O Hermes suporta cron jobs para tarefas agendadas:

```
"Me lembre de revisar o código todo dia às 9h"
"Verifique a saúde do bot a cada 30 minutos"
"Poste ofertas no canal às 8h, 12h e 18h"
```

## Dicas de segurança

1. **Sempre use `allowed_chats`** — restringe acesso ao seu ID
2. **Nunca compartilhe API keys** — use `.env`
3. **Faça backup do `/opt/data`** periodicamente
4. **Não rode como root** — o container já isola isso
5. **Use whitelist no BotFather** — desative "Group Privacy" se necessário

## Performance

Se o Hermes estiver lento:

```bash
# Ver uso de recursos
htop

# Limpar cache
rm -rf /opt/data/.cache/

# Verificar espaço
df -h

# Reiniciar gateway
docker restart hermes-gateway
```

## Recursos

- [Documentação oficial](https://hermes-agent.nousresearch.com/docs)
- [Nous Research](https://nousresearch.com)
- [Umbrel OS](https://umbrel.com)
- [OpenRouter](https://openrouter.ai)
