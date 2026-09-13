#!/usr/bin/env bash
# Liefert build/web unter /<repository>/ aus und startet den Browser-Durchgang
# dagegen. EINE Stelle für deploy-web.yml und webtest-gegenprobe.yml — zwei
# Kopien liefen sonst auseinander.
#
# Aufruf:  tool/webtest_serve.sh [--gegenprobe]
set -euo pipefail

REPO_NAME="${GITHUB_REPOSITORY##*/}"
REPO_NAME="${REPO_NAME:-vox}"
PORT=8765

# ⚠️ Die App ist mit --base-href "/<repo>/" gebaut. Sie muss deshalb unter genau
# diesem Pfad ausgeliefert werden — unter "/" lädt sie ihre eigenen Dateien
# nicht und der Durchgang meldete einen Fehler, den es online nicht gibt.
SERVE_ROOT="$(mktemp -d)"
mkdir -p "$SERVE_ROOT/$REPO_NAME"
cp -r build/web/. "$SERVE_ROOT/$REPO_NAME/"

python3 -m http.server "$PORT" --directory "$SERVE_ROOT" >/dev/null 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true; rm -rf "$SERVE_ROOT"' EXIT

# Warten, bis der Server wirklich antwortet — ein festes sleep reicht mal und
# mal nicht.
for _ in $(seq 1 30); do
  if curl -sf "http://localhost:$PORT/$REPO_NAME/index.html" >/dev/null; then
    break
  fi
  sleep 1
done

python3 tool/webtest_ci.py "$@" "http://localhost:$PORT/$REPO_NAME/"
