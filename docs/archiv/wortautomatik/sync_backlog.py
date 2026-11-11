#!/usr/bin/env python3
# FILE: tool/sync_backlog.py
# PHASE: فاز A, Schritt A.2 (2026-09-15)
# PURPOSE: Setzt die ✓-Marken in old files Lukasalmani/Wörter/*.txt neu —
#          abgeleitet aus assets/vocab/. Behebt den Audit-Befund vom
#          2026-09-15: 87 Karten vorhanden, aber nur 6 Marken gesetzt.
#
#   python3 tool/sync_backlog.py --dry-run   # nur zeigen, nichts schreiben
#   python3 tool/sync_backlog.py             # Marken schreiben
#
# Idempotent: zweimal laufen lassen ändert beim zweiten Mal nichts.
# Die Marken sind ab jetzt NUR noch Anzeige — die Wahrheit ist assets/vocab/.
import argparse
import os
import sys

from backlog import WOERTER_DIR, GRUPPEN, ARTIKEL, vokab_id, vorhandene_ids, VOCAB_DIR

# Auch die Summendatei mitpflegen, damit sie nicht widersprüchlich dasteht.
# Sie wird im Backlog übersprungen (Duplikat), soll aber lesbar bleiben.
ZUSAETZLICH = [("substantiv_singular_alle.txt", "nomen")]


def dateien():
    """[(dateiname, wortart)] über alle Gruppen + die Summendatei."""
    raus = []
    for eintraege in GRUPPEN.values():
        for datei, wortart, _artikel in eintraege:
            raus.append((datei, wortart))
    raus.extend(ZUSAETZLICH)
    return raus


def sync(wurzel=".", dry_run=False):
    da = vorhandene_ids(os.path.join(wurzel, VOCAB_DIR))
    gesamt_neu = gesamt_weg = 0

    for datei, wortart in dateien():
        pfad = os.path.join(wurzel, WOERTER_DIR, datei)
        if not os.path.exists(pfad):
            print(f"⚠️  fehlt: {pfad}", file=sys.stderr)
            continue

        with open(pfad, encoding="utf-8") as f:
            zeilen = f.read().split("\n")

        neu_markiert = entmarkiert = markiert_gesamt = 0
        raus = []
        for zeile in zeilen:
            roh = zeile.strip()
            if not roh:
                raus.append(zeile)
                continue
            war_markiert = roh.startswith("✓")
            lemma = roh[1:].strip() if war_markiert else roh
            if not lemma:
                raus.append(zeile)
                continue
            # Artikel im Lemma tolerieren, falls jemand ihn eingetragen hat.
            teile = lemma.split(" ")
            if len(teile) > 1 and teile[0].lower() in ARTIKEL:
                lemma_fuer_id = " ".join(teile[1:])
            else:
                lemma_fuer_id = lemma
            fertig = vokab_id(wortart, lemma_fuer_id) in da
            if fertig:
                markiert_gesamt += 1
                if not war_markiert:
                    neu_markiert += 1
                raus.append(f"✓ {lemma}")
            else:
                if war_markiert:
                    entmarkiert += 1
                raus.append(lemma)

        inhalt = "\n".join(raus)
        geaendert = inhalt != "\n".join(zeilen)
        gesamt_neu += neu_markiert
        gesamt_weg += entmarkiert
        status = "unverändert" if not geaendert else (
            f"+{neu_markiert} neu, -{entmarkiert} entfernt")
        print(f"{datei:<42} {markiert_gesamt:>5} markiert   {status}")
        if geaendert and not dry_run:
            with open(pfad, "w", encoding="utf-8") as f:
                f.write(inhalt)

    print(f"\n════ Sync-Bericht ════\n"
          f"neu markiert: {gesamt_neu} · Marken entfernt: {gesamt_weg}"
          f"{'  [DRY-RUN — nichts geschrieben]' if dry_run else ''}")
    return gesamt_neu, gesamt_weg


def main():
    ap = argparse.ArgumentParser(description="✓-Marken aus assets/vocab neu setzen")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--wurzel", default=".")
    a = ap.parse_args()
    sync(a.wurzel, a.dry_run)


if __name__ == "__main__":
    main()
