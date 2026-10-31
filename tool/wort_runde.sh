#!/usr/bin/env bash
# FILE: tool/wort_runde.sh
# PHASE: L.4 — Routine «ده کلمه جدید» (PLAN.md → «📚 روال»), Schritte 5–7.
#        Gleiche Befehle, gleiche Reihenfolge wie im PLAN — nur gebündelt,
#        damit kein Schritt vergessen wird.
# Aufruf (im Repo-Ordner, Flutter im PATH):
#   bash tool/wort_runde.sh /tmp/batch.json          alles in einem Aufruf
#   bash tool/wort_runde.sh --teil 1 /tmp/batch.json Dry-Run ⇒ Import ⇒ Index ⇒ ✓ ⇒ analyze
#   bash tool/wort_runde.sh --teil 2                 Tests ohne grammatik_uebungen_test.dart
#   bash tool/wort_runde.sh --teil 3                 grammatik_uebungen_test.dart ⇒ nächste 10
#   bash tool/wort_runde.sh --teil daten /tmp/batch.json
#        NUR Dart-SDK (source tool/dart_umgebung.sh): Dry-Run ⇒ Import ⇒ Index
#        ⇒ ✓ ⇒ nächste 10 — ohne analyze/test. Erlaubt NUR, solange lib/,
#        test/, pubspec.* und analysis_options.yaml unverändert sind (wird
#        vor und nach der Runde geprüft). analyze + test laufen vollständig in
#        deploy-web.yml VOR der Veröffentlichung: rot ⇒ kein Deploy, die
#        laufende App bleibt unverändert (2026-10-31, Lukas).
# Die Teile 1–3 zusammen = genau der Gesamtlauf; sie gibt es, weil die volle
# Testsuite (~5 Min.) in Umgebungen mit Zeitlimit pro Befehl nicht in einen
# Aufruf passt (2026-10-26). Reihenfolge 1 ⇒ 2 ⇒ 3 einhalten.
# Bricht beim ersten Problem ab (Fehler ODER Warnung im Dry-Run ⇒ nichts wird
# geschrieben). Danach bleibt nur: PLAN/MAP eintragen ⇒ commit ⇒ push ⇒ CI prüfen.
# `dart <datei>` statt `dart run <datei>`: gleiches Programm, aber ohne den
# automatischen pub-Lauf, der ohne Flutter-SDK scheitern würde (2026-10-31).
set -euo pipefail

teil="alle"
if [[ "${1:-}" == "--teil" ]]; then
  teil="${2:?Teil fehlt (1, 2 oder 3)}"
  shift 2
fi
langsam="test/grammatik_uebungen_test.dart"

daten_schritte() {
  local batch="${1:?Pfad zur JSON-Datei fehlt (z. B. /tmp/batch.json)}"
  echo "── 5a · Dry-Run"
  local ausgabe
  ausgabe="$(dart tool/vokabular_import.dart --dry-run "$batch")" || { echo "$ausgabe"; exit 1; }
  echo "$ausgabe" | tail -n 20
  if ! grep -q "Fehler: 0 · Warnungen: 0" <<<"$ausgabe"; then
    echo "⛔ Dry-Run nicht sauber (Fehler oder Warnungen) — nichts geschrieben." >&2
    exit 1
  fi
  echo "── 5b · Import"
  dart tool/vokabular_import.dart "$batch" | tail -n 3
  echo "── 6 · Index + ✓ in den Listen"
  dart tool/vokab_index.dart | tail -n 3
  dart tool/naechste_woerter.dart --abhaken
}

teil_1() {
  daten_schritte "${1:-}"
  echo "── 7a · analyze"
  flutter analyze
}

# App-Code unberührt? Sonst gehört die Runde in den vollen Flutter-Lauf.
code_unberuehrt() {
  local geaendert
  geaendert="$(git status --porcelain -- lib test pubspec.yaml pubspec.lock analysis_options.yaml)"
  if [[ -n "$geaendert" ]]; then
    echo "⛔ App-Code geändert — «--teil daten» nicht erlaubt, voller Lauf mit Flutter nötig:" >&2
    echo "$geaendert" >&2
    exit 1
  fi
}

teil_daten() {
  code_unberuehrt
  daten_schritte "${1:-}"
  code_unberuehrt
  echo "── Nächste Wörter"
  dart tool/naechste_woerter.dart
  echo "✅ Runde fertig (analyze + test laufen in deploy-web.yml vor dem Deploy)."
  echo "   Jetzt: PLAN/MAP ⇒ commit ⇒ push ⇒ CI prüfen (rot ⇒ sofort beheben)."
}

teil_2() {
  echo "── 7b · Tests (ohne $langsam)"
  local dateien
  dateien="$(find test -name '*_test.dart' ! -path "$langsam" | sort)"
  # shellcheck disable=SC2086
  flutter test $dateien
}

teil_3() {
  echo "── 7c · Tests ($langsam)"
  flutter test "$langsam"
  echo "── Nächste Wörter"
  dart tool/naechste_woerter.dart
  echo "✅ Runde fertig. Jetzt: PLAN/MAP ⇒ commit ⇒ push ⇒ CI prüfen."
}

case "$teil" in
  alle) teil_1 "${1:-}"; teil_2; teil_3 ;;
  1) teil_1 "${1:-}" ;;
  2) teil_2 ;;
  3) teil_3 ;;
  daten) teil_daten "${1:-}" ;;
  *) echo "⛔ Unbekannter Teil: $teil (erlaubt: 1, 2, 3, daten)" >&2; exit 1 ;;
esac
