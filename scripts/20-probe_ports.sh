#/bin/bash install.sh
# 20-probe_ports.sh
#!/usr/bin/env bash
set -euo pipefail
ALIVE=${1:-out/recon/alive.txt}
OUT=${2:-out}
mkdir -p "$OUT/ports"

# 1) Fast TCP port scan
naabu -silent -top-ports 1000 -rate 5000 -l "$ALIVE" -o "$OUT/ports/naabu_top.txt" || true

# 2) Merge host:port -> normalized URLs for http services
# httpx can auto-detect scheme and grab titles/status/tech
cat "$OUT/ports/naabu_top.txt" | httpx -silent -ports xlarge -status-code -title -tech-detect \
  -o "$OUT/ports/httpx_full.txt" || true

# trimmed URLs only
cut -d' ' -f1 "$OUT/ports/httpx_full.txt" > "$OUT/ports/httpx_urls.txt" || true

echo "[*] Port probe complete:"
wc -l "$OUT"/ports/*
