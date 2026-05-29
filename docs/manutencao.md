# Manutenção — Hermes Agent no Umbrel

## Limpeza de disco

O container acumula cache com o tempo. Limpe periodicamente:

```bash
# Ver uso total
du -sh /opt/data/

# Ver pastas maiores
du -sh /opt/data/*/ | sort -rh

# Limpar cache do uv (gerenciador de pacotes)
rm -rf /opt/data/.cache/uv/

# Limpar cache npm
rm -rf /opt/data/.npm/

# Limpar backups antigos de config
rm -f /opt/data/config.yaml.bak.*

# Limpar pycache
find /opt/data -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
```

### O que NUNCA remover

| Arquivo | Motivo |
|---|---|
| `.env` | Contém API keys |
| `state.db` | Banco de dados do gateway |
| `skills/` | Skills instaladas |
| `memories/` | Memórias de longo prazo |
| `sessions/` | Histórico de conversas |
| `config.yaml` | Configuração principal |

## Backup

```bash
# Backup da config
cp /opt/data/config.yaml /opt/data/config.yaml.bak.$(date +%Y%m%d)

# Backup completo
tar -czf /opt/data-backup-$(date +%Y%m%d).tar.gz \
  /opt/data/config.yaml \
  /opt/data/.env \
  /opt/data/SOUL.md \
  /opt/data/skills/ \
  /opt/data/memories/
```

## Monitoramento

```bash
# Ver processos
ps aux | grep hermes

# Ver logs em tempo real
tail -f /opt/data/logs/gateway.log

# Ver uso de disco
df -h

# Ver uso de memória
free -h
```

## Reiniciar o gateway

Pelo dashboard do Umbrel:
1. Vá em **Apps** → **Hermes Agent**
2. Clique em **Restart**

Ou pelo terminal:

```bash
docker restart hermes-gateway
```

## Atualizações

> ⚠️ **NÃO execute `hermes update` manualmente.**

Atualizações são gerenciadas pelo Umbrel OS:
1. Notificação aparece no dashboard
2. Clique em **Update**
3. O Umbrel baixa o novo Docker image e reinicia

Se você atualizar manualmente, pode quebrar o container.
