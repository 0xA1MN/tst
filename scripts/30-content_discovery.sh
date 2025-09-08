#/bin/bash install.sh
# 30-content_discovery.sh
#!/usr/bin/env bash
set -euo pipefail
URLS=${1:-out/ports/httpx_urls.txt}
WORDLIST=${2:-wordlists/content.txt}
OUT=${3:-out}
mkdir -p "$OUT/content"

# Light content discovery using katana depth + known param endpoints from history (already in recon/urls.txt).
# If you prefer aggressive brute-forcing, plug your favorite tool (e.g., ffuf) here.
if [ -s "$URLS" ]; then
  katana -silent -list "$URLS" -d 2 -o "$OUT/content/katana_deep.txt" || true
  sort -u "$OUT/content/katana_deep.txt" > "$OUT/content/urls_deep.txt"
fi

# Optional: parameter harvesting from archives
grep -Eo '\?.+=' out/recon/urls.txt | cut -d'?' -f2 | tr '&' '\n' | cut -d'=' -f1 | sort -u > "$OUT/content/params.txt" || true

echo "[*] Content discovery complete:"
wc -l "$OUT"/content/*
