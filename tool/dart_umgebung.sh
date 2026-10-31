# FILE: tool/dart_umgebung.sh
# PHASE: L.4 — Routine «ده کلمه جدید» (PLAN.md → «📚 روال»), Schritt 2.
# ZWECK: Für Wortrunden (nur Daten, kein App-Code) reicht das reine Dart-SDK —
#        die Werkzeuge (vokabular_import, vokab_index, naechste_woerter) und
#        vokab_schema.dart importieren kein Flutter. Statt Flutter (>1 GB +
#        pub get) lädt dieses Skript nur das Dart-SDK (~240 MB, Sekunden).
#        analyze + test laufen weiter vollständig in deploy-web.yml VOR jeder
#        Veröffentlichung (rot ⇒ kein Deploy).
#
# Aufruf (im Repo-Ordner, mit `source`, damit PATH gesetzt bleibt):
#   source tool/dart_umgebung.sh
#
# Die Dart-Version wird NICHT von Hand gepflegt: sie ist genau die Dart-Version
# der Flutter-Version aus .github/workflows/deploy-web.yml (Flutter-Release-
# Liste). Wird Flutter dort angehoben, folgt Dart hier automatisch.
#
# package_config: `flutter pub get` geht ohne Flutter nicht. Darum wird eine
# minimale .dart_tool/package_config.json geschrieben, die nur `package:vox`
# auf lib/ zeigt. Eine von pub erzeugte Datei (Flutter-Umgebung) wird NIE
# überschrieben — nur die eigene (generator = tool/dart_umgebung.sh).
# Bewusst ohne `set -e`: das Skript wird mit `source` geladen.

_vox_dart_umgebung() {
  local repo workflow flutter_version dart_version ziel sprache config
  repo="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "⛔ Nicht im Repo-Ordner." >&2; return 1; }
  workflow="$repo/.github/workflows/deploy-web.yml"

  flutter_version="$(grep -m1 -E '^\s*flutter-version:' "$workflow" | sed -E 's/.*flutter-version:\s*//; s/\s*$//')"
  [[ -n "$flutter_version" ]] || { echo "⛔ flutter-version in $workflow nicht gefunden." >&2; return 1; }

  dart_version="$(curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
    | python3 -c "
import json, sys
v = sys.argv[1]
for r in json.load(sys.stdin)['releases']:
    if r['version'] == v and r['channel'] == 'stable':
        print(r['dart_sdk_version']); break
" "$flutter_version")"
  [[ -n "$dart_version" ]] || { echo "⛔ Dart-Version zu Flutter $flutter_version nicht gefunden." >&2; return 1; }

  ziel="${VOX_DART_HOME:-/tmp/dart-sdk-$dart_version}"
  if [[ ! -x "$ziel/bin/dart" ]]; then
    echo "── Dart $dart_version (= Flutter $flutter_version) laden"
    local tmp; tmp="$(mktemp -d)"
    curl -fsSL -o "$tmp/dart.zip" \
      "https://storage.googleapis.com/dart-archive/channels/stable/release/$dart_version/sdk/dartsdk-linux-x64-release.zip" \
      || { echo "⛔ Download fehlgeschlagen." >&2; rm -rf "$tmp"; return 1; }
    unzip -q "$tmp/dart.zip" -d "$tmp" && rm -rf "$ziel" && mv "$tmp/dart-sdk" "$ziel"
    rm -rf "$tmp"
  fi
  export PATH="$ziel/bin:$PATH"

  # languageVersion = Untergrenze der SDK-Bedingung in pubspec.yaml (wie pub).
  sprache="$(grep -m1 -E '^\s*sdk:\s*\^?[0-9]' "$repo/pubspec.yaml" | sed -E 's/^[^0-9]*([0-9]+)\.([0-9]+).*/\1.\2/')"
  [[ -n "$sprache" ]] || { echo "⛔ SDK-Bedingung in pubspec.yaml nicht gefunden." >&2; return 1; }

  config="$repo/.dart_tool/package_config.json"
  if [[ -f "$config" ]] && ! grep -q '"generator": "tool/dart_umgebung.sh"' "$config"; then
    echo "ℹ️  $config stammt von pub (Flutter-Umgebung) — bleibt unverändert."
  else
    mkdir -p "$repo/.dart_tool"
    cat > "$config" <<EOF
{
  "configVersion": 2,
  "generator": "tool/dart_umgebung.sh",
  "packages": [
    {"name": "vox", "rootUri": "../", "packageUri": "lib/", "languageVersion": "$sprache"}
  ]
}
EOF
  fi

  echo "✅ $(dart --version 2>&1) — bereit für: bash tool/wort_runde.sh --teil daten /tmp/batch.json"
}

_vox_dart_umgebung
