#!/usr/bin/env bash
# FILE: tool/wort_runde.sh
# PHASE: L.4 — Routine «ده کلمه جدید» (PLAN.md → «📚 روال»), Schritte 5–7 in
#        EINEM Aufruf. Gleiche Befehle, gleiche Reihenfolge wie im PLAN —
#        nur gebündelt, damit kein Schritt vergessen wird.
# Aufruf (im Repo-Ordner, Flutter im PATH):  bash tool/wort_runde.sh /tmp/batch.json
# Bricht beim ersten Problem ab (Fehler ODER Warnung im Dry-Run ⇒ nichts wird
# geschrieben). Danach bleibt nur: PLAN/MAP eintragen ⇒ commit ⇒ push ⇒ CI prüfen.
set -euo pipefail
batch="${1:?Pfad zur JSON-Datei fehlt (z. B. /tmp/batch.json)}"

echo "── 5a · Dry-Run"
ausgabe="$(dart run tool/vokabular_import.dart --dry-run "$batch")" || { echo "$ausgabe"; exit 1; }
echo "$ausgabe" | tail -n 20
if ! grep -q "Fehler: 0 · Warnungen: 0" <<<"$ausgabe"; then
  echo "⛔ Dry-Run nicht sauber (Fehler oder Warnungen) — nichts geschrieben." >&2
  exit 1
fi

echo "── 5b · Import"
dart run tool/vokabular_import.dart "$batch" | tail -n 3

echo "── 6 · Index + ✓ in den Listen"
dart run tool/vokab_index.dart | tail -n 3
dart run tool/naechste_woerter.dart --abhaken

echo "── 7 · analyze + test"
flutter analyze
flutter test

echo "── Nächste Wörter"
dart run tool/naechste_woerter.dart
echo "✅ Runde fertig. Jetzt: PLAN/MAP ⇒ commit ⇒ push ⇒ CI prüfen."
