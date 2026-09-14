#!/usr/bin/env python3
# FILE: tool/backlog.py
# PHASE: فاز A, Schritt A.1 (2026-09-15)
# PURPOSE: Sagt, welche Wörter als Nächstes dran sind — abgeleitet aus dem,
#          was WIRKLICH da ist (assets/vocab/), nicht aus den ✓-Marken.
#          Audit 2026-09-15: die Marken waren um 81 Karten im Rückstand.
#
#   python3 tool/backlog.py --stand                 # Abdeckung je Wortart
#   python3 tool/backlog.py --naechste 10           # nächste 10 Wörter
#   python3 tool/backlog.py --naechste 10 --gruppe adjektive
#   python3 tool/backlog.py --naechste 10 --json    # für generate_words.py
#
# KEINE Validierung hier — die liegt allein in
# lib/features/vokabular/data/vokab_schema.dart (eine Quelle, Regel فاز A).
import argparse
import json
import os
import sys

WOERTER_DIR = "old files Lukasalmani/Wörter"
VOCAB_DIR = "assets/vocab"

# Quelldatei → (wortart, artikel-oder-None)
# substantiv_singular_alle.txt ist bewusst NICHT dabei: es ist die Summe von
# der/die/das und würde jedes Nomen doppelt in den Backlog holen. Über die
# drei Einzeldateien kennen wir zusätzlich den Artikel — den will der
# SUPER-PROMPT als Teil des Lemmas ("der Tisch", Regel 6).
GRUPPEN = {
    "adjektive": [("Adjektive.txt", "adjektiv", None)],
    "verben": [
        ("Verben_regelmaesig.txt", "verb", None),
        ("Verben_unregelmaeßig_Infinitiv.txt", "verb", None),
    ],
    "nomen": [
        ("substantiv_singular_der.txt", "nomen", "der"),
        ("substantiv_singular_die.txt", "nomen", "die"),
        ("substantiv_singular_das.txt", "nomen", "das"),
    ],
}
# Reihenfolge der Abarbeitung — Nutzerentscheidung 2026-07-14: Adjektive zuerst.
GRUPPEN_REIHENFOLGE = ["adjektive", "verben", "nomen"]

ARTIKEL = {"der", "die", "das"}


def vokab_id(wortart: str, wort: str) -> str:
    """Spiegelt vokabId() aus vokab_schema.dart — ID-Regel 5.

    Muss zeichengenau dasselbe liefern wie die Dart-Fassung, sonst hält der
    Duplikat-Schutz nicht und Wörter werden doppelt erzeugt.
    """
    lemma = wort.strip()
    teile = lemma.split(" ")
    if len(teile) > 1 and teile[0].lower() in ARTIKEL:
        lemma = " ".join(teile[1:])
    lemma = (
        lemma.lower()
        .replace("ä", "ae")
        .replace("ö", "oe")
        .replace("ü", "ue")
        .replace("ß", "ss")
        .replace(" ", "_")
    )
    return f"{wortart}_{lemma}"


def vorhandene_ids(vocab_dir: str = VOCAB_DIR) -> set:
    """Alle bereits erzeugten Karten — die einzige Wahrheit über den Fortschritt."""
    ids = set()
    if not os.path.isdir(vocab_dir):
        return ids
    for wortart in sorted(os.listdir(vocab_dir)):
        ordner = os.path.join(vocab_dir, wortart)
        if not os.path.isdir(ordner):
            continue
        for datei in os.listdir(ordner):
            if datei.endswith(".json"):
                ids.add(datei[:-5])
    return ids


def lies_liste(pfad: str) -> list:
    """Eine Quelldatei → Liste roher Lemmata (✓-Marke entfernt, leere Zeilen weg)."""
    woerter = []
    with open(pfad, encoding="utf-8") as f:
        for zeile in f:
            z = zeile.strip()
            if not z:
                continue
            if z.startswith("✓"):
                z = z[1:].strip()
            if z:
                woerter.append(z)
    return woerter


def backlog(gruppe=None, wurzel="."):
    """[(gruppe, wortart, lemma_fuer_prompt, id, erledigt)] in Listenreihenfolge."""
    da = vorhandene_ids(os.path.join(wurzel, VOCAB_DIR))
    gruppen = [gruppe] if gruppe else GRUPPEN_REIHENFOLGE
    zeilen = []
    gesehen = set()
    for g in gruppen:
        if g not in GRUPPEN:
            raise SystemExit(f"Unbekannte Gruppe: {g} (erlaubt: {', '.join(GRUPPEN)})")
        for datei, wortart, artikel in GRUPPEN[g]:
            pfad = os.path.join(wurzel, WOERTER_DIR, datei)
            if not os.path.exists(pfad):
                print(f"⚠️  fehlt: {pfad}", file=sys.stderr)
                continue
            for lemma in lies_liste(pfad):
                wid = vokab_id(wortart, lemma)
                if wid in gesehen:      # z. B. Verb in beiden Verblisten
                    continue
                gesehen.add(wid)
                fuer_prompt = f"{artikel} {lemma}" if artikel else lemma
                zeilen.append((g, wortart, fuer_prompt, wid, wid in da))
    return zeilen


def main():
    ap = argparse.ArgumentParser(description="VOX Wort-Backlog (فاز A / A.1)")
    ap.add_argument("--stand", action="store_true", help="Abdeckung je Gruppe zeigen")
    ap.add_argument("--naechste", type=int, metavar="N", help="nächste N offene Wörter")
    ap.add_argument("--gruppe", choices=list(GRUPPEN), help="nur diese Gruppe")
    ap.add_argument("--json", action="store_true", help="Ausgabe als JSON")
    ap.add_argument("--wurzel", default=".", help="Repo-Wurzel (Standard: .)")
    a = ap.parse_args()

    zeilen = backlog(a.gruppe, a.wurzel)

    if a.stand or not a.naechste:
        summe_auf = summe_ges = 0
        print("Gruppe        erledigt /  gesamt   offen")
        print("─" * 44)
        for g in (([a.gruppe] if a.gruppe else GRUPPEN_REIHENFOLGE)):
            teil = [z for z in zeilen if z[0] == g]
            auf = sum(1 for z in teil if z[4])
            summe_auf += auf
            summe_ges += len(teil)
            print(f"{g:<12} {auf:>8} / {len(teil):>7} {len(teil)-auf:>7}")
        print("─" * 44)
        anteil = (summe_auf / summe_ges * 100) if summe_ges else 0
        print(f"{'SUMME':<12} {summe_auf:>8} / {summe_ges:>7} "
              f"{summe_ges-summe_auf:>7}   ({anteil:.2f} %)")
        # Karten, die in keiner Liste stehen (z. B. aus den Themen-Decks)
        alle_ids = {z[3] for z in zeilen}
        extra = sorted(vorhandene_ids(os.path.join(a.wurzel, VOCAB_DIR)) - alle_ids)
        if extra:
            print(f"\n{len(extra)} Karten stehen in keiner Quellliste "
                  f"(aus Themen-Decks), z. B.: {', '.join(extra[:5])}")
        if not a.naechste:
            return

    offen = [z for z in zeilen if not z[4]][: a.naechste]
    if a.json:
        print(json.dumps(
            [{"gruppe": g, "wortart": w, "wort": lemma, "id": i}
             for g, w, lemma, i, _ in offen],
            ensure_ascii=False, indent=2))
    else:
        print(f"\nNächste {len(offen)} Wörter:")
        for g, w, lemma, i, _ in offen:
            print(f"  {lemma:<32} → {i}")


if __name__ == "__main__":
    main()
