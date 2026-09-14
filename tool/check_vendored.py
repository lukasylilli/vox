#!/usr/bin/env python3
# FILE: tool/check_vendored.py
# PHASE: فاز S (2026-09-15)
# PURPOSE: Wacht über die aus Root-in übernommenen Dateien. Wir teilen bewusst
#          keinen Code (beide Repos bleiben eigenständig, PLAN.md → فاز S) —
#          der Preis dafür ist, dass Kopien auseinanderlaufen können. Dieses
#          Skript meldet genau das.
#
#   python3 tool/check_vendored.py
#
# Meldet eine ABWEICHUNG (Rückgabe 0, kein Fehler!) — die Entscheidung, ob die
# Kopie nachgezogen wird, trifft immer ein Mensch. Nur ein kaputter Eintrag
# (Datei fehlt, Herkunft unlesbar) ist ein echter Fehler (Rückgabe 1).
import json
import os
import re
import sys
import urllib.parse
import urllib.request

API = "https://api.github.com/repos/lukasylilli/Root-in/commits"

# ziel (hier) → quelle (Root-in). Die Herkunft steht zusätzlich im Dateikopf.
KOPIEN = {
    "lib/core/utils/persistent_storage.dart":
        "lib/core/services/web_storage/request_persistent_storage.dart",
    "lib/core/utils/persistent_storage_io.dart":
        "lib/core/services/web_storage/request_persistent_storage_io.dart",
    "lib/core/utils/persistent_storage_web.dart":
        "lib/core/services/web_storage/request_persistent_storage_web.dart",
}


def notierter_commit(pfad):
    """Liest den 'commit <sha>'-Vermerk aus dem Dateikopf."""
    try:
        with open(pfad, encoding="utf-8") as f:
            kopf = f.read(4000)
    except FileNotFoundError:
        return None
    treffer = re.search(r"commit\s+([0-9a-f]{40})", kopf)
    return treffer.group(1) if treffer else None


def letzter_commit(quelle):
    """Neuester Commit der Quelldatei in Root-in.

    Ohne Token drosselt GitHub anonyme Abfragen hart (403). In der Automatik
    liegt GITHUB_TOKEN bereit; lokal geht es meist auch ohne.
    """
    url = f"{API}?path={urllib.parse.quote(quelle)}&per_page=1"
    kopf = {"Accept": "application/vnd.github+json"}
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        kopf["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, headers=kopf)
    with urllib.request.urlopen(req, timeout=30) as a:
        daten = json.loads(a.read().decode())
    return daten[0]["sha"] if daten else None


def main():
    fehler = abweichungen = 0
    for ziel, quelle in KOPIEN.items():
        notiert = notierter_commit(ziel)
        if not notiert:
            print(f"❌ {ziel}: keine Herkunft im Dateikopf (oder Datei fehlt)")
            fehler += 1
            continue
        try:
            aktuell = letzter_commit(quelle)
        except Exception as e:
            print(f"⚠️  {ziel}: Root-in nicht erreichbar ({e}) — übersprungen")
            continue
        if aktuell and aktuell != notiert:
            print(f"⚠️  ABWEICHUNG {ziel}\n"
                  f"    Kopie von : {notiert[:10]}\n"
                  f"    Original  : {aktuell[:10]}  ({quelle})\n"
                  f"    → prüfen, ob die Änderung hierher gehört. "
                  f"Danach den commit-Vermerk im Dateikopf nachziehen.")
            abweichungen += 1
        else:
            print(f"✅ {ziel} — aktuell ({notiert[:10]})")

    print(f"\n{len(KOPIEN)} Kopien · {abweichungen} Abweichung(en) · {fehler} Fehler")
    sys.exit(1 if fehler else 0)


if __name__ == "__main__":
    main()
