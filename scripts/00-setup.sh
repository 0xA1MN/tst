#/bin/bash install.sh
# 00-setup.sh
#!/usr/bin/env bash
set -euo pipefail

# Install recon stack via static binaries
apk add --no-cache curl unzip git jq bash coreutils

BIN=/usr/local/bin

grab() {
  url="$1"; out="$2"
  curl -sSL "$url" -o "$out"
  chmod +x "$out"
}

# ProjectDiscovery tools (latest stable tags usually ok)
grab https://github.com/projectdiscovery/subfinder/releases/latest/download/subfinder_amd64.apk /tmp/subfinder.apk || true
apk add --allow-untrusted /tmp/subfinder.apk || true

grab https://github.com/projectdiscovery/httpx/releases/latest/download/httpx_amd64.apk /tmp/httpx.apk || true
apk add --allow-untrusted /tmp/httpx.apk || true

grab https://github.com/projectdiscovery/naabu/releases/latest/download/naabu_amd64.apk /tmp/naabu.apk || true
apk add --allow-untrusted /tmp/naabu.apk || true

grab https://github.com/projectdiscovery/dnsx/releases/latest/download/dnsx_amd64.apk /tmp/dnsx.apk || true
apk add --allow-untrusted /tmp/dnsx.apk || true

grab https://github.com/projectdiscovery/katana/releases/latest/download/katana_amd64.apk /tmp/katana.apk || true
apk add --allow-untrusted /tmp/katana.apk || true

# nuclei binary (static tar)
NUC_TAR=$(mktemp)
curl -sSL https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_amd64.zip -o "$NUC_TAR"
unzip -o "$NUC_TAR" -d /usr/local/bin > /dev/null

# waybackurls + gau via go? Use containers avoided; minimalist: fetch ready-built (small)
curl -sSL https://github.com/tomnomnom/hacks/raw/master/waybackurls/waybackurls -o $BIN/waybackurls && chmod +x $BIN/waybackurls || true
curl -sSL https://github.com/lc/gau/releases/latest/download/gau_amd64 -o $BIN/gau && chmod +x $BIN/gau || true

mkdir -p "$NUCLEI_TPLS" out/recon out/ports out/content out/nuclei
# pull public nuclei templates cache
nuclei -ut || true
