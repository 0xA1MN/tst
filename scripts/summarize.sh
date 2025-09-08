#/bin/bash install.sh
# summarize.sh
#!/usr/bin/env bash
set -euo pipefail

echo "#### Recon"
[ -f recon/alive.txt ] && echo "- Alive hosts: $(wc -l < recon/alive.txt)"
[ -f recon/urls.txt ] && echo "- URLs (archive+crawl): $(wc -l < recon/urls.txt)"

echo ""
echo "#### Ports & HTTP Probe"
[ -f ports/naabu_top.txt ] && echo "- Hosts with open top ports: $(wc -l < ports/naabu_top.txt)"
[ -f ports/httpx_urls.txt ] && echo "- HTTP(S) endpoints: $(wc -l < ports/httpx_urls.txt)"

echo ""
echo "#### Content Discovery"
[ -f content/urls_deep.txt ] && echo "- Deep URLs (katana d=2): $(wc -l < content/urls_deep.txt)"

echo ""
echo "#### DAST – Nuclei"
if [ -f nuclei/findings.csv ]; then
  CRIT=$(grep -ci ',critical,' nuclei/findings.csv || true)
  HIGH=$(grep -ci ',high,' nuclei/findings.csv || true)
  MED=$(grep -ci ',medium,' nuclei/findings.csv || true)
  LOW=$(grep -ci ',low,' nuclei/findings.csv || true)
  echo "- Findings: critical=$CRIT, high=$HIGH, medium=$MED, low=$LOW"
  echo "- Sample:"
  head -n 5 nuclei/findings.csv | sed 's/^/  /'
else
  echo "- No nuclei findings file produced."
fi

echo ""
echo "#### DAST – ZAP"
if [ -f zap/report_json.json ]; then
  HI=$(jq '.site[].alerts[] | select(.risk=="High") | 1' zap/report_json.json | wc -l)
  MED=$(jq '.site[].alerts[] | select(.risk=="Medium") | 1' zap/report_json.json | wc -l)
  LOW=$(jq '.site[].alerts[] | select(.risk=="Low") | 1' zap/report_json.json | wc -l)
  echo "- ZAP Alerts: High=$HI, Medium=$MED, Low=$LOW"
else
  echo "- ZAP not run or no report available."
fi

echo ""
echo "#### SAST"
echo "- Semgrep, Gitleaks, and Trivy SARIF uploaded to Code Scanning Alerts."
