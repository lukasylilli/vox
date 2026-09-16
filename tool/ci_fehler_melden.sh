#!/usr/bin/env bash
# FILE: tool/ci_fehler_melden.sh
# PHASE: L.1b (2026-09-16)
# ZWECK: Macht den Fehlertext eines roten CI-Schritts als GitHub-Annotation
#        sichtbar.
#
# WARUM: Claude kann die Logs der Läufe nicht lesen (sie liegen auf
# *.blob.core.windows.net, außerhalb seiner Netz-Freigabe). Annotationen
# dagegen liefert api.github.com (check-runs/<job>/annotations). Ohne das
# musste die Ursache jedes roten Laufs aus dem Diff erraten werden.
#
#   tool/ci_fehler_melden.sh "<Titel>" <logdatei>
#
# Schreibt die ersten relevanten Zeilen (höchstens 120) als EINE Annotation;
# Zeilenumbrüche werden nach GitHub-Regel kodiert (%0A), `%` als %25.
set -u
titel="$1"
datei="$2"
[ -f "$datei" ] || { echo "::error title=$titel::(keine Ausgabe gefunden)"; exit 0; }
text=$(grep -v '^[[:space:]]*$' "$datei" | head -n 120 \
  | sed -e 's/%/%25/g' -e 's/\r/%0D/g' | sed -e ':a;N;$!ba;s/\n/%0A/g')
echo "::error title=${titel}::${text}"
