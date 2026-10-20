#!/usr/bin/env bash
# Gera o projeto Vega OS (VPKG) do PlusTV ou do TxGold.
# Uso:  ./generate.sh plustv|txgold [dono]     (dono opcional = link /player/<dono>)
# Requer: Vega SDK instalado (Ubuntu 20.04+ ou macOS) e Node 18+. NÃO funciona no Windows.
set -euo pipefail
BRAND="${1:-plustv}"; OWNER="${2:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
case "$BRAND" in
  plustv) NAME=plustv; PKG=com.plustv.player; B="";;
  txgold) NAME=txgold; PKG=com.txgold.player; B="txgold";;
  *) echo "marca invalida: $BRAND (use plustv ou txgold)"; exit 1;;
esac
[ -n "$OWNER" ] && { NAME="$NAME-$OWNER"; PKG="$PKG.p$(echo "$OWNER" | tr -c 'a-zA-Z0-9\n' '_' | tr 'A-Z' 'a-z')"; }
OUT="$HERE/out/$NAME"; rm -rf "$OUT"; mkdir -p "$HERE/out"
command -v vega >/dev/null || { echo "Vega SDK nao encontrado. Instale: curl -fsSL https://sdk-installer.vega.labcollab.net/get_vvm.sh | bash && source ~/vega/env"; exit 1; }
vega project generate --template vegaWebview --name "$NAME" --packageId "$PKG" --outputDir "$HERE/out"
cd "$OUT"
APP=$(find src -maxdepth 2 -name 'App.tsx' | head -1); [ -z "$APP" ] && APP=src/App.tsx
sed -e "s#__PANEL__#https://konnex.business#" \
    -e "s#__DISCOVERY__#https://raw.githubusercontent.com/plustvuhd/plustv-config/main/plustv.json#" \
    -e "s#__OWNER__#$OWNER#" -e "s#__BRAND__#$B#" "$HERE/App.tsx.tmpl" > "$APP"
# manifest: versao do SO (sem isso o build falha) e categoria principal da Amazon
vega project update-manifest --os-min 1.2 --os-version 1.2 || true
grep -q 'com.amazon.category.main' manifest.toml || echo "AVISO: confira no manifest.toml se a categoria com.amazon.category.main esta presente"
# HTTPS apenas: o painel e o discovery sao HTTPS, nao precisa liberar cleartext
npm install
npm run build:app
echo; echo "Pacotes gerados:"; find build -name '*.vpkg'
echo "Envie o armv7 (Fire TV Stick) e o aarch64/x86_64 no Developer Console, aba do app, como binario Vega."
