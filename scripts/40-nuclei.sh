#/bin/bash install.sh
# 40-nuclei.sh
#!/usr/bin/env bash
set -euo pipefail
URLS=${1:-out/ports/httpx_urls.txt}
OUT=${2:-out}
mkdir -p "$OUT/nuclei"

# Update templates (public). If you have private ones in repo, add -t nuclei-templates
nuclei -update-templates || true

NUCLEI_ARGS=(
  -silent
  -l "$URLS"
  -severity critical,high,medium,low
  -rl 150
  -c 200
  -irr         # include redirect responses
  -o "$OUT/nuclei/findings.txt"
  -jsonl
)

# Include your private templates if present
if [ -d nuclei-templates ]; then
  NUCLEI_ARGS+=(-t nuclei-templates)
fi

# Run core template sets
nuclei "${NUCLEI_ARGS[@]}" -as -tags cves,exposures,misconfig,default-logins,tech > "$OUT/nuclei/findings.jsonl" || true

# Quick CSV
jq -r '
  [.templateID, .info.severity, .host, .matchedAt, (.extractedResults|join(";") // ""), .matcher_name] | @csv
' "$OUT/nuclei/findings.jsonl" > "$OUT/nuclei/findings.csv" || true

echo "[*] Nuclei done. Lines:"
wc -l "$OUT"/nuclei/*
