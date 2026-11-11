#!/usr/bin/env python3
# FILE: tool/generate_words.py
# PHASE: فاز A, Schritt A.3 (2026-09-15)
# PURPOSE: Erzeugt Wortkarten automatisch — nimmt die nächsten offenen Wörter
#          aus tool/backlog.py, schickt sie durch den SUPER-PROMPT v3.0 und
#          legt das Ergebnis in import_inbox/ ab. Danach übernimmt wie bisher
#          `dart run tool/vokabular_import.dart`.
#
#   ANTHROPIC_API_KEY=… python3 tool/generate_words.py --anzahl 20
#   … --gruppe adjektive --pro-batch 5 --dry-run
#
# ⚠️ GRENZE DIESES SKRIPTS: es validiert NICHT. Der Pre-Flight unten fängt nur
#    grobe Ausfälle ab (kaputtes JSON, falsche Wortzahl), damit kein sinnloser
#    Import-Lauf startet. Verbindlich ist allein vokabPruefeKarte() in
#    lib/features/vokabular/data/vokab_schema.dart — dieselbe Quelle für App,
#    Tests und Import. Es darf keine zweite Validierungslogik geben.
#
# ⚠️ OBERGRENZE (Audit 2026-09-15): vokabular_controller.dart lädt beim Start
#    JEDE Karte aus assets/vocab/. Bis V.2 (vocab.db) fertig ist, liegt die
#    sichere Grenze bei ~500 Karten insgesamt. Das Skript bricht darüber ab.
import argparse
import datetime
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

from backlog import backlog, vorhandene_ids, VOCAB_DIR

PROMPT_DATEI = "old files Lukasalmani/Wort prompt"
PLATZHALTER = "[HIER WÖRTER EINFÜGEN]"
INBOX = "import_inbox"
API_URL = "https://api.anthropic.com/v1/messages"

# Modellname bewusst als Vorgabe und nicht fest verdrahtet — Modelle werden
# abgelöst. Über --modell bzw. VOX_MODELL überschreibbar.
STANDARD_MODELL = os.environ.get("VOX_MODELL", "claude-sonnet-5")

# Schutzgrenze bis V.2 (vocab.db) steht. Über --grenze anhebbar, wenn V.2 da ist.
KARTEN_GRENZE = 500

PFLICHT = ("wort", "wortart", "uebersetzung", "niveau", "details")


def lade_prompt(wurzel="."):
    pfad = os.path.join(wurzel, PROMPT_DATEI)
    with open(pfad, encoding="utf-8") as f:
        text = f.read()
    if PLATZHALTER not in text:
        raise SystemExit(
            f"'{PLATZHALTER}' steht nicht in {PROMPT_DATEI} — "
            "wurde der Prompt umgebaut? Nicht raten, erst nachsehen.")
    return text


def api_aufruf(prompt, modell, max_tokens, api_key, versuche=3):
    """Ein Aufruf; bei 429/5xx mit wachsender Pause neu versuchen."""
    daten = json.dumps({
        "model": modell,
        "max_tokens": max_tokens,
        "messages": [{"role": "user", "content": prompt}],
    }).encode()
    kopf = {
        "content-type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01",
    }
    letzter = None
    for n in range(versuche):
        try:
            req = urllib.request.Request(API_URL, data=daten, headers=kopf)
            with urllib.request.urlopen(req, timeout=600) as a:
                return json.loads(a.read().decode())
        except urllib.error.HTTPError as e:
            rumpf = e.read().decode(errors="replace")[:400]
            letzter = f"HTTP {e.code}: {rumpf}"
            if e.code not in (408, 409, 429, 500, 502, 503, 529):
                break
        except Exception as e:                     # Netz, Timeout
            letzter = repr(e)
        pause = 5 * (2 ** n)
        print(f"   … Versuch {n+1} fehlgeschlagen ({letzter}) — {pause}s Pause",
              file=sys.stderr)
        time.sleep(pause)
    raise RuntimeError(f"API-Aufruf endgültig fehlgeschlagen: {letzter}")


def text_aus(antwort):
    return "".join(b.get("text", "") for b in antwort.get("content", [])
                   if b.get("type") == "text")


def preflight(rohtext, erwartet):
    """Grobprüfung. Gibt (karten, probleme) zurück — karten=None heißt unbrauchbar.

    Bewusst schwach: alles Feine macht vokabPruefeKarte() in Dart.
    """
    probleme = []
    s = rohtext.strip()
    if s.startswith("```"):                        # Regel 1 verbietet Fences …
        s = re.sub(r"^```[a-zA-Z]*\s*", "", s)     # … Modelle setzen sie trotzdem
        if s.endswith("```"):
            s = s[:-3]
        s = s.strip()
        probleme.append("Code-Fences entfernt (Regel 1 verletzt)")
    try:
        daten = json.loads(s)
    except json.JSONDecodeError as e:
        return None, [f"JSON nicht lesbar: {e}"]
    if isinstance(daten, dict):
        daten = [daten]
        probleme.append("Einzelobjekt statt Array (Regel 1)")
    if not isinstance(daten, list):
        return None, ["Antwort ist weder Array noch Objekt"]
    if len(daten) != erwartet:
        probleme.append(f"{len(daten)} Karten statt {erwartet}")
    brauchbar = []
    for k in daten:
        if not isinstance(k, dict):
            probleme.append("Eintrag ist kein Objekt — verworfen")
            continue
        fehlt = [f for f in PFLICHT if not k.get(f)]
        if fehlt:
            probleme.append(
                f"'{k.get('wort', '?')}' ohne {', '.join(fehlt)} — verworfen "
                "(wäre in Dart ein fataler Fehler)")
            continue
        brauchbar.append(k)
    return (brauchbar or None), probleme


def main():
    ap = argparse.ArgumentParser(description="VOX Wort-Generator (فاز A / A.3)")
    ap.add_argument("--anzahl", type=int, default=10, help="wie viele Wörter insgesamt")
    ap.add_argument("--pro-batch", type=int, default=5,
                    help="Wörter je API-Aufruf (Prompt erlaubt 1–10)")
    ap.add_argument("--gruppe", help="adjektive | verben | nomen")
    ap.add_argument("--modell", default=STANDARD_MODELL)
    ap.add_argument("--max-tokens", type=int, default=32000)
    ap.add_argument("--grenze", type=int, default=KARTEN_GRENZE,
                    help="Sicherheitsgrenze Gesamtkarten (bis V.2 fertig ist)")
    ap.add_argument("--dry-run", action="store_true",
                    help="nur zeigen, welche Wörter drankämen — kein API-Aufruf")
    ap.add_argument("--wurzel", default=".")
    a = ap.parse_args()

    if not 1 <= a.pro_batch <= 10:
        raise SystemExit("--pro-batch muss zwischen 1 und 10 liegen (SUPER-PROMPT v3.0)")

    vorhanden = len(vorhandene_ids(os.path.join(a.wurzel, VOCAB_DIR)))
    if vorhanden + a.anzahl > a.grenze:
        erlaubt = max(0, a.grenze - vorhanden)
        print(f"⛔ Sicherheitsgrenze: {vorhanden} Karten vorhanden, Grenze {a.grenze}.\n"
              f"   Es passen noch {erlaubt} Wörter. Grund: vokabular_controller.dart\n"
              f"   lädt beim Start jede Karte — erst V.2 (vocab.db) hebt die Grenze auf.\n"
              f"   Bewusst mehr wollen? --grenze setzen.", file=sys.stderr)
        if erlaubt == 0:
            sys.exit(3)
        a.anzahl = erlaubt

    offen = [z for z in backlog(a.gruppe, a.wurzel) if not z[4]][: a.anzahl]
    if not offen:
        print("Nichts offen — Backlog dieser Gruppe ist leer.")
        return
    print(f"{len(offen)} Wörter, {a.pro_batch} je Aufruf, Modell {a.modell}\n")

    if a.dry_run:
        for _g, _w, lemma, wid, _ in offen:
            print(f"  {lemma:<32} → {wid}")
        print("\n[DRY-RUN] kein API-Aufruf, keine Datei geschrieben.")
        return

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise SystemExit("ANTHROPIC_API_KEY ist nicht gesetzt.")

    vorlage = lade_prompt(a.wurzel)
    inbox = os.path.join(a.wurzel, INBOX)
    os.makedirs(inbox, exist_ok=True)
    heute = datetime.date.today().isoformat()
    gruppe_name = a.gruppe or "gemischt"

    ein_summe = aus_summe = geschrieben = 0
    alle_probleme = []

    batches = [offen[i:i + a.pro_batch] for i in range(0, len(offen), a.pro_batch)]
    for nr, batch in enumerate(batches, 1):
        woerter = [z[2] for z in batch]
        print(f"── Batch {nr}/{len(batches)}: {', '.join(woerter)}")
        prompt = vorlage.replace(PLATZHALTER, "\n".join(woerter))
        try:
            antwort = api_aufruf(prompt, a.modell, a.max_tokens, api_key)
        except RuntimeError as e:
            print(f"   ❌ {e}", file=sys.stderr)
            alle_probleme.append(f"Batch {nr}: {e}")
            continue

        nutzung = antwort.get("usage", {})
        ein_summe += nutzung.get("input_tokens", 0)
        aus_summe += nutzung.get("output_tokens", 0)
        if antwort.get("stop_reason") == "max_tokens":
            alle_probleme.append(
                f"Batch {nr}: Antwort bei max_tokens abgeschnitten — "
                "--pro-batch senken oder --max-tokens erhöhen")

        karten, probleme = preflight(text_aus(antwort), len(batch))
        for p in probleme:
            print(f"   ⚠️  {p}")
            alle_probleme.append(f"Batch {nr}: {p}")
        if not karten:
            print("   ❌ nichts Brauchbares — Batch übersprungen", file=sys.stderr)
            continue

        ziel = os.path.join(inbox, f"batch_{heute}_{gruppe_name}_{nr:03d}.json")
        with open(ziel, "w", encoding="utf-8") as f:
            json.dump(karten, f, ensure_ascii=False, indent=2)
            f.write("\n")
        geschrieben += len(karten)
        print(f"   ✅ {len(karten)} Karten → {ziel}")

    print(f"\n════ Generator-Bericht ════\n"
          f"Karten in import_inbox/: {geschrieben} · Probleme: {len(alle_probleme)}\n"
          f"Tokens: {ein_summe} rein / {aus_summe} raus")
    if alle_probleme:
        print("\n⚠️  Probleme:")
        for p in alle_probleme:
            print(f"  · {p}")
    print("\nNächster Schritt (verbindliche Prüfung):\n"
          "  dart run tool/vokabular_import.dart\n"
          "  python3 tool/sync_backlog.py")
    if geschrieben == 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
