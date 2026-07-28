# 🔧 Manutenção & Troubleshooting

> Mantenha seu Hermes Agent saudável no Umbrel.

---

## Rotina semanal (5 minutos)

```bash
# 1. Verificar saúde
docker ps | grep hermes
tail -20 /opt/data/logs/gateway.log | grep -i "error\|warn"

# 2. Espaço em disco
df -h /opt/data

# 3. Limpeza rápida
bash scripts/cleanup.sh
```

---

## Limpeza de disco

O container acumula cache com o tempo. Execute periodicamente:

### Script automatizado

```bash
bash scripts/cleanup.sh           # Limpeza normal
bash scripts/cleanup.sh --dry-run # Só mostrar o que seria removido
```

### Limpeza manual

```bash
# Ver maiores pastas
du -sh /opt/data/*/ | sort -rh | head -10

# Cache do gerenciador de pacotes Python
rm -rf /opt/data/.cache/uv/
rm -rf /opt/data/.cache/pip/

# Cache npm (se usar WhatsApp/plugins Node)
rm -rf /opt/data/.npm/

# Backups antigos de config (manter o último)
ls -t /opt/data/config.yaml.bak.* 2>/dev/null | tail -n +2 | xargs rm -f

# Python cache
find /opt/data -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null

# Logs antigos (manter últimos 7 dias)
find /opt/data/logs/ -name "*.log" -mtime +7 -delete
```

### ⚠️ O que NUNCA remover

| Arquivo/Pasta | Consequência da remoção |
|---|---|
| `.env` | **Agente para de funcionar** (perde API keys) |
| `state.db` | **Perde todo histórico** de conversas |
| `config.yaml` | **Agente volta ao padrão** de fábrica |
| `skills/` | Perde todas as skills instaladas |
| `memories/` | Agente "esquece" quem você é |
| `SOUL.md` | Perde a personalidade customizada |

---

## Backup

### Backup essencial (recomendado)

```bash
#!/bin/bash
BACKUP_DIR="/opt/data/hermes-backups"
mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/hermes-$(date +%Y%m%d-%H%M).tar.gz" \
  /opt/data/config.yaml \
  /opt/data/.env \
  /opt/data/SOUL.md \
  /opt/data/skills/ \
  /opt/data/memories/

# Manter últimos 7 backups
ls -t "$BACKUP_DIR"/hermes-*.tar.gz | tail -n +8 | xargs rm -f
```

### Backup completo (estado + configuração)

```bash
tar -czf hermes-full-$(date +%Y%m%d).tar.gz /opt/data/
```

> ⚠️ Backup completo inclui `state.db` (pode ser grande — 100MB+). Para restaurar, pare o gateway primeiro: `docker stop hermes-gateway`.

---

## Monitoramento

```bash
# Status dos processos
ps aux | grep hermes

# Logs em tempo real
tail -f /opt/data/logs/gateway.log

# Uso de disco
df -h /opt/data

# Uso de memória
free -h

# Top 10 pastas por tamanho
du -sh /opt/data/*/ | sort -rh | head -10
```

### Healthcheck automatizado (cron job)

Peça ao Hermes para criar um monitor:

> "Crie um cron job que verifique a saúde do gateway a cada 30 minutos e me avise no Telegram se algo estiver errado."

---

## Reiniciar o gateway

### Pelo dashboard do Umbrel

1. Apps → **Hermes Agent**
2. Clique em **Restart**

### Pelo terminal

```bash
docker restart hermes-gateway
```

### Reinicialização forçada (gateway travado)

```bash
docker stop hermes-gateway
sleep 5
docker start hermes-gateway
```

---

## Atualizações

> ⚠️ **NUNCA execute `hermes update`.** Atualizações manuais quebram o container.

O Umbrel OS gerencia atualizações automaticamente:

1. Nova versão disponível → notificação no dashboard
2. Clique em **Update**
3. Umbrel baixa a nova Docker image e recria o container
4. `/opt/data` é preservado (volume persistente)

---

## Troubleshooting

### Bot não responde no Telegram

```bash
# 1. Gateway está rodando?
docker ps | grep hermes-gateway

# 2. Logs mostram erros?
tail -50 /opt/data/logs/gateway.log

# 3. Token está correto?
grep TELEGRAM /opt/data/.env

# 4. Testar conectividade com Telegram API
curl -s "https://api.telegram.org/bot$(grep TELEGRAM_BOT_TOKEN /opt/data/.env | cut -d= -f2)/getMe"
```

### Gateway em crash loop

```bash
# Ver erro exato
docker logs hermes-gateway --tail 100

# Causas comuns:
# - API key inválida → verificar .env
# - config.yaml com sintaxe YAML quebrada → validar
# - Porta em conflito → verificar docker ps

# Resetar estado
docker stop hermes-gateway
docker start hermes-gateway
```

### "Resource not accessible by personal access token" (GitHub)

O token GitHub não tem escopo suficiente:

```bash
# Atualizar escopos do token
gh auth refresh -h github.com -s repo,workflow

# Ou criar token novo em https://github.com/settings/tokens
# com scopes: repo, workflow
```

### Config perdida após update

**Causa:** arquivo foi colocado fora de `/opt/data`.

**Solução:** sempre coloque configurações em `/opt/data/config.yaml` e `/opt/data/.env`. Arquivos em outros paths são descartados nos updates do Umbrel.

### Sem espaço em disco

```bash
# Diagnóstico
df -h /opt/data
du -sh /opt/data/*/ | sort -rh | head -10

# Ação imediata
bash scripts/cleanup.sh

# Se ainda estiver cheio:
# - Verificar tamanho do state.db (pode crescer com muitas sessões)
# - Remover image_cache/ e audio_cache/ (mídia recebida)
# - Limpar sessions/ antigas
```

### WhatsApp desconecta

O plugin Baileys perde a sessão após períodos longos sem uso ou quando o celular principal desconecta.

**Solução:** reescanear o QR code (Settings → Dispositivos conectados → Conectar).

### DNS não resolve `umbrel.local`

```bash
# Use o IP diretamente
ip addr show | grep "inet " | grep -v 127.0.0.1

# Ou configure no /etc/hosts do seu computador:
# 192.168.0.X  umbrel.local
```

---

## Logs importantes

| Log | Localização | Quando consultar |
|---|---|---|
| Gateway | `/opt/data/logs/gateway.log` | Bot offline, erros de conexão |
| Cron | `/opt/data/logs/cron.log` | Jobs agendados não executam |
| Docker | `docker logs hermes-gateway` | Container não inicia |

---

## Próximo passo

- [`README.md`](../README.md) — Visão geral e instalação
- [`configuracao.md`](configuracao.md) — Referência completa de configuração
