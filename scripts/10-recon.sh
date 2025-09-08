#/bin/bash install.sh
# 10-recon.sh
#!/usr/bin/env bash
set -euo pipefail
ROOTS=${1:-targets/roots.txt}
OUT=${2:-out}

: "${ROOTS:?roots file required}"
mkdir -p "$OUT/recon"

# 1) Passive subdomain enumeration
subfinder -silent -all -dL "$ROOTS" -o "$OUT/recon/subs_raw.txt"

# 2) Resolve (dnsx) -> only valid A/AAAA/CNAME
dnsx -silent -a -resp-only -l "$OUT/recon/subs_raw.txt" -o "$OUT/recon/subs_resolved.txt"

# 3) Alive (httpx)
httpx -silent -threads 200 -status-code -no-color -l "$OUT/recon/subs_resolved.txt" \
  -o "$OUT/recon/alive_full.txt"
cut -d' ' -f1 "$OUT/recon/alive_full.txt" > "$OUT/recon/alive.txt"

# 4) Crawl URLs with katana + wayback sources (wide net)
katana -silent -list "$OUT/recon/alive.txt" -o "$OUT/recon/katana_urls.txt" || true
waybackurls < "$OUT/recon/alive.txt" | sort -u > "$OUT/recon/wayback_urls.txt" || true
gau --providers wayback,otx,commoncrawl,alienvault -random-agent -subs -o "$OUT/recon/gau_urls.txt" -from "$OUT/recon/alive.txt" || true

sort -u "$OUT/recon/katana_urls.txt" "$OUT/recon/wayback_urls.txt" "$OUT/recon/gau_urls.txt" > "$OUT/recon/urls.txt"

echo "[*] Recon done:"
wc -l "$OUT"/recon/*
