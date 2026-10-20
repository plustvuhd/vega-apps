#!/usr/bin/env bash
set -euo pipefail
BRAND="${1:-plustv}"; OWNER="${2:-}"
HERE="$(cd "$(dirname "$0")" && pwd)"
case "$BRAND" in
  plustv) NAME=plustv; PKG=com.plustv.player; B="";;
  txgold) NAME=txgold; PKG=com.txgold.player; B="txgold";;
  *) echo "marca invalida: $BRAND (use plustv ou txgold)"; exit 1;;
esac
if [ -n "$OWNER" ]; then
  NAME="$NAME-$OWNER"
  PKG="$PKG.p$(echo "$OWNER" | tr -c 'a-zA-Z0-9\n' '_' | tr 'A-Z' 'a-z')"
fi
rm -rf "$HERE/out"; mkdir -p "$HERE/out"
command -v vega >/dev/null || { echo "Vega SDK nao encontrado"; exit 1; }
echo "== vega project list-templates =="
vega project list-templates || true
echo "== vega project generate =="
vega project generate --template vegaWebview --name "$NAME" --packageId "$PKG" --outputDir "$HERE/out" < /dev/null || {
  echo "ERRO no generate. Ajuda do comando:"; vega project generate --help || true; exit 1; }
echo "== arquivos criados =="
find "$HERE/out" -maxdepth 3 -not -path '*/node_modules*' | head -60
MF=$(find "$HERE/out" -name manifest.toml -not -path '*/node_modules/*' | head -1)
[ -z "$MF" ] && { echo "ERRO: nao achei manifest.toml, o projeto nao foi criado"; exit 1; }
OUT="$(dirname "$MF")"
echo "Projeto em: $OUT"
cd "$OUT"
APP=$(find . -name 'App.tsx' -not -path './node_modules/*' | head -1)
[ -z "$APP" ] && APP=./src/App.tsx
mkdir -p "$(dirname "$APP")"
sed -e "s#__PANEL__#https://konnex.business#" \
    -e "s#__DISCOVERY__#https://raw.githubusercontent.com/plustvuhd/plustv-config/main/plustv.json#" \
    -e "s#__OWNER__#$OWNER#" -e "s#__BRAND__#$B#" "$HERE/App.tsx.tmpl" > "$APP"
echo "App.tsx gravado em $APP"
vega project update-manifest --os-min 1.2 --os-version 1.2 || true
grep -q 'com.amazon.category.main' manifest.toml || echo "AVISO: confira a categoria com.amazon.category.main no manifest.toml"
npm install
npm run build:app
echo "Pacotes gerados:"
find . -name '*.vpkg' -not -path './node_modules/*'
