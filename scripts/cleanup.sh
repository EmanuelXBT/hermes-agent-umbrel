#!/bin/bash
# cleanup.sh — Script de limpeza do Hermes Agent no Umbrel
# Uso: bash cleanup.sh [--dry-run]

set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

DATA="/opt/data"
SAVED=0

log() { echo "[cleanup] $1"; }
run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "  [dry-run] $*"
    else
        eval "$@"
    fi
}

log "Iniciando limpeza do Hermes..."
log "Uso atual: $(du -sh "$DATA" | cut -f1)"

# 1. Cache do uv
if [[ -d "$DATA/.cache/uv" ]]; then
    SIZE=$(du -sh "$DATA/.cache/uv" | cut -f1)
    log "Removendo cache uv ($SIZE)..."
    run "rm -rf $DATA/.cache/uv"
    SAVED=$((SAVED + 1))
fi

# 2. Cache npm
if [[ -d "$DATA/.npm" ]]; then
    SIZE=$(du -sh "$DATA/.npm" | cut -f1)
    log "Removendo cache npm ($SIZE)..."
    run "rm -rf $DATA/.npm"
    SAVED=$((SAVED + 1))
fi

# 3. Backups antigos de config (manter último)
log "Limpando backups antigos de config..."
run "ls -t $DATA/config.yaml.bak.* 2>/dev/null | tail -n +2 | xargs rm -f"

# 4. pycache
log "Removendo __pycache__..."
run "find $DATA -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true"

# 5. get-pip.py (se existir)
if [[ -f "$DATA/get-pip.py" ]]; then
    log "Removendo get-pip.py..."
    run "rm -f $DATA/get-pip.py"
fi

log "Uso após limpeza: $(du -sh "$DATA" | cut -f1)"
log "Limpeza concluída. Itens removidos: $SAVED"
