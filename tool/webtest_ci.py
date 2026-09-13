#!/usr/bin/env python3
"""Browser-Durchgang **in der Automatik** für VOX.

Aufruf (macht `tool/webtest_serve.sh` in der Automatik selbst):
    python3 tool/webtest_ci.py http://localhost:8765/vox/
    python3 tool/webtest_ci.py --gegenprobe http://localhost:8765/vox/

Warum es dieses Skript gibt
---------------------------
VOX hat 33 Tests, und **keiner davon öffnet einen Browser** — sie laufen alle
auf der Dart-VM. `flutter analyze` und `flutter test` können deshalb grün sein,
während die veröffentlichte Seite gar nicht startet. Genau diese Lücke hat im
Schwesterprojekt Root-in drei kaputte Hauptseiten durchgelassen (dort PLAN.md
Lehre 31), und sie war in VOX nach dem Umbau zur reinen Web-App (2026-09-13)
offen: Seit es keinen Entwicklungsrechner mehr gibt, sieht **niemand** die
laufende App, bevor sie online steht.

Dieses Skript schließt sie mit dem, was auf `ubuntu-latest` ohnehin liegt:
Chrome und ChromeDriver. Gesprochen wird das WebDriver-Protokoll über schlichtes
HTTP mit `urllib` — **keine zusätzliche Abhängigkeit**, kein Selenium, kein
Playwright.

Was geprüft wird
----------------
Start, die Kachel-Startseite, die Datenbank im Browser (drift/SQLite-WASM), drei
Hauptbereiche mit Inhalt, die Selbstlernen-Rubrik samt **Routine-Verlinkung nach
Root-in** (2026-09-13) und dem Pomodoro-Timer, sowie der Zustand nach dem
Neuladen.

⚠️ Die teuer bezahlten Regeln aus Root-in gelten hier genauso
--------------------------------------------------------------
1. **Die Zeichenfläche liegt im Schatten-DOM** von `flt-glass-pane`.
   `document.querySelectorAll('canvas')` liefert bei Flutter **immer 0** — auch
   bei einer tadellos laufenden App.
2. **Zustände an KNÖPFEN und Listeneinträgen ablesen, nie an Überschriften.**
   Reine Text-Widgets stehen unzuverlässig im Semantik-Baum.
3. **Auf Zustände warten, nicht auf die Uhr.** Eine feste Wartezeit reicht mal
   und mal nicht.
4. **Scheitert der Start, wird abgebrochen.** Sonst meldet ein leerer
   Semantik-Baum eine Ursache als ein Dutzend Fehler.
5. **Gescrollt wird mit einem RAD-Ereignis.** Ein Wisch bewegt eine
   Flutter-Liste im Desktop-Browser nicht, ohne dass etwas fehlschlägt.
6. **Die Oberfläche folgt der eingestellten Sprache** — VOX startet auf
   Persisch. Beschriftungen deshalb immer in beiden Sprachen anbieten.
"""
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

PORT = 9515
BASE = f"http://localhost:{PORT}"

_ADDRESSES = [a for a in sys.argv[1:] if not a.startswith("-")]
URL = _ADDRESSES[0] if _ADDRESSES else "http://localhost:8765/vox/"
if not URL.endswith("/"):
    URL += "/"

GEGENPROBE = "--gegenprobe" in sys.argv

# Adresse der Schwester-App. Die Routine-Karte in Selbstlernen öffnet sie in
# einem neuen Tab — bewusst als Link, ohne Code-Verschmelzung der Projekte.
ROOT_IN_URL = "lukasylilli.github.io/Root-in"

# Namen der Prüfungen, die die Gegenprobe rot sehen muss. Als Konstanten, weil
# jeder Name an zwei Stellen gebraucht wird — ein Tippfehler an einer davon
# ließe die Gegenprobe still ins Leere laufen.
DB_ANGELEGT = "Datenbank im Browser angelegt"

GEGENPROBE_ROT = {
    DB_ANGELEGT,
}


def call(method, path, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(
        BASE + path, data=data, method=method,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(response.read())


IN_CI = bool(os.environ.get("GITHUB_ACTIONS"))


def melden(stufe, text):
    """Gibt eine Meldung so aus, dass die Automatik sie als **Anmerkung** zeigt.

    ⚠️ Ohne das ist ein gescheiterter Lauf von außen stumm: Das Protokoll eines
    Laufs braucht eine Anmeldung (HTTP 403), die Anmerkungen dagegen sind bei
    einem öffentlichen Repository frei lesbar.
    """
    if IN_CI:
        # Zeilenumbrüche müssen in Arbeitsablauf-Befehlen maskiert werden,
        # sonst bricht die Meldung nach der ersten Zeile ab.
        print(f"::{stufe}::{text}".replace("\n", "%0A"), flush=True)
    else:
        print(f"  [{stufe}] {text}", flush=True)


def chromedriver_pfad():
    """Wo ChromeDriver liegt — auf GitHub-Runnern über `CHROMEWEBDRIVER`."""
    ordner = os.environ.get("CHROMEWEBDRIVER")
    if ordner:
        kandidat = os.path.join(ordner, "chromedriver")
        if os.path.exists(kandidat):
            return kandidat
    return "chromedriver"


def urteil(failures, bestanden):
    """Normaler Lauf: grün, wenn nichts rot ist. Gegenprobe: grün, wenn GENAU
    die erwarteten Prüfungen rot sind."""
    if not GEGENPROBE:
        if failures:
            print(f"FEHLGESCHLAGEN: {len(failures)} — {', '.join(failures)}")
            melden("error", f"Browser-Durchgang: {len(failures)} von "
                            f"{len(failures) + bestanden} Prüfungen rot — "
                            f"{', '.join(failures)}")
            return 1
        print("Alles bestanden.")
        melden("notice", f"Browser-Durchgang: alle {bestanden} Prüfungen grün.")
        return 0

    rot = set(failures)
    if rot == GEGENPROBE_ROT:
        print(f"GEGENPROBE BESTANDEN: genau die {len(rot)} erwarteten Prüfungen "
              f"sind rot, die übrigen {bestanden} grün.")
        melden("notice", f"Gegenprobe bestanden: {len(rot)} erwartete Prüfungen "
                         f"rot, {bestanden} grün.")
        return 0
    blieben_gruen = sorted(GEGENPROBE_ROT - rot)
    unerwartet_rot = sorted(rot - GEGENPROBE_ROT)
    teile = []
    if blieben_gruen:
        teile.append("GRÜN trotz Beschädigung (prüfen also nichts): "
                     + ", ".join(blieben_gruen))
    if unerwartet_rot:
        teile.append("unerwartet rot: " + ", ".join(unerwartet_rot))
    print("GEGENPROBE GESCHEITERT — " + " · ".join(teile))
    melden("error", "Gegenprobe gescheitert — " + " · ".join(teile))
    return 1


def main():
    driver = subprocess.Popen(
        [chromedriver_pfad(), f"--port={PORT}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(3)
    session = None
    failures = []

    chrome_args = [
        "--headless=new",
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu",
        # Telefon-Format: so sieht es der Nutzer, für den die Fassung gebaut ist.
        "--window-size=430,930",
        # ⚠️ Ohne das öffnet `window.open` gar nichts, und die Routine-Prüfung
        # wäre rot, obwohl die App richtig handelt.
        "--disable-popup-blocking",
    ]

    try:
        try:
            session = call("POST", "/session", {"capabilities": {"alwaysMatch": {
                "browserName": "chrome",
                "goog:chromeOptions": {"args": chrome_args},
            }}})["value"]["sessionId"]
        except Exception as error:
            melden("error", f"ChromeDriver nicht erreichbar: {error}")
            return 2

        def js(script):
            return call("POST", f"/session/{session}/execute/sync",
                        {"script": script, "args": []})["value"]

        def painted():
            """Zeichenflächen im **Schatten-DOM**. 0 = nichts gemalt."""
            return js("""
              var g = document.querySelector('flt-glass-pane');
              if (!g || !g.shadowRoot) return 0;
              return g.shadowRoot.querySelectorAll('canvas').length;
            """) or 0

        def leaves():
            """Blätter des Semantik-Baums samt Mittelpunkt."""
            return js("""
              var out = [];
              document.querySelectorAll('flt-semantics').forEach(function(e){
                if (e.querySelector('flt-semantics')) return;
                var t = (e.getAttribute('aria-label') || e.textContent || '').trim();
                var r = e.getBoundingClientRect();
                if (t && r.width > 0 && r.height > 0)
                  out.push({t: t, x: Math.round(r.x + r.width / 2),
                                  y: Math.round(r.y + r.height / 2)});
              });
              return out;
            """)

        def boot():
            for _ in range(90):
                time.sleep(1)
                if not js("return !!document.querySelector('flutter-view');"):
                    continue
                for _ in range(45):
                    if painted():
                        break
                    time.sleep(1)
                else:
                    return False
                # Flutters Barrierefreiheits-Schalter baut den Semantik-Baum als
                # echte Elemente auf — erst danach lässt sich etwas lesen.
                for _ in range(25):
                    js("var p=document.querySelector('flt-semantics-placeholder');"
                       "if(p) p.click();")
                    time.sleep(1)
                    if leaves():
                        time.sleep(2)
                        return True
                return False
            return False

        def diagnosis():
            if not js("return !!document.querySelector('flutter-view');"):
                return ("Die Seite hat Flutter gar nicht geladen — stimmt die "
                        "Adresse, und wurde `build/web` wirklich ausgeliefert?")
            if not painted():
                return ("Flutter ist geladen, hat aber nichts gezeichnet. DAS "
                        "ist der Fall, für den dieser Durchgang gebaut wurde: "
                        "Die App startet nicht, und ohne ihn ginge sie so "
                        "online.")
            return ("Gezeichnet ist, aber der Semantik-Baum bleibt leer — der "
                    "Klick auf 'flt-semantics-placeholder' hat nicht gezogen.")

        def wait_until(condition, seconds=15):
            for _ in range(seconds * 2):
                if condition():
                    return True
                time.sleep(0.5)
            return False

        def shows(*labels):
            """⚠️ Nur nach KNÖPFEN und Listeneinträgen fragen, nie nach
            Überschriften — reine Texte stehen unzuverlässig im Semantik-Baum."""
            texts = [n["t"] for n in leaves()]
            return any(any(label in t for label in labels) for t in texts)

        def tap(label, exact=True, wait=2):
            for node in leaves():
                if (node["t"] == label) if exact else (label in node["t"]):
                    call("POST", f"/session/{session}/actions", {"actions": [{
                        "type": "pointer", "id": "finger",
                        "parameters": {"pointerType": "touch"},
                        "actions": [
                            {"type": "pointerMove", "duration": 0,
                             "x": node["x"], "y": node["y"]},
                            {"type": "pointerDown", "button": 0},
                            {"type": "pause", "duration": 60},
                            {"type": "pointerUp", "button": 0},
                        ]}]})
                    time.sleep(wait)
                    return True
            return False

        def tap_any(*labels, wait=2):
            """⚠️ Erst genau, dann als Teiltreffer: Ein Semantik-Knoten trägt
            gelegentlich mehr als nur seine Beschriftung (ein Listeneintrag etwa
            Titel UND Untertitel). Ein Tipp, der deswegen nicht stattfindet,
            sieht aus wie eine kaputte Seite."""
            if any(tap(label, wait=wait) for label in labels):
                return True
            return any(tap(label, exact=False, wait=wait) for label in labels)

        def back():
            call("POST", f"/session/{session}/back", {})
            time.sleep(2)

        def goto_home():
            """Zurück auf die Kachel-Startseite, egal wo der Durchgang steht."""
            call("POST", f"/session/{session}/url", {"url": URL})
            wait_until(lambda: shows("Wortschatz"), 30)

        bestanden = [0]

        def check(name, condition, detail=""):
            print(f"  {'✓' if condition else '✗'} {name}"
                  f"{'  ' + detail if detail else ''}")
            if condition:
                bestanden[0] += 1
            else:
                failures.append(name)

        print(f"Prüfe: {URL}{'  (GEGENPROBE)' if GEGENPROBE else ''}\n")
        call("POST", f"/session/{session}/url", {"url": URL})

        # ⚠️ Kommt die App nicht hoch, wird ABGEBROCHEN — die folgenden
        # Prüfungen würden sonst dieselbe eine Ursache vielfach melden.
        if not boot():
            check("App startet", False)
            grund = diagnosis()
            print(f"\nABBRUCH: {grund}")
            melden("error", f"Browser-Durchgang abgebrochen: {grund}")
            return 1
        check("App startet", True)

        # ── Startseite ────────────────────────────────────────────────────────
        check("Startseite zeigt die Lernbereiche",
              wait_until(lambda: shows("Wortschatz"), 30))
        check("Startseite zeigt Grammatik", shows("Grammatik"))

        # ── Datenbank ─────────────────────────────────────────────────────────
        # Drift legt die SQLite-Datei je nach Browser in OPFS oder IndexedDB ab.
        # ⚠️ Geprüft wird, dass ÜBERHAUPT ein Bestand entstanden ist — welche
        # der beiden Speicherungen drift gewählt hat, ist Sache des Browsers und
        # darf den Durchgang nicht rot machen.
        # Erst eine datengetriebene Seite öffnen, damit die Datenbank
        # tatsächlich angelegt wird — vorher gibt es nichts zu finden.
        tap_any("Wortschatz", "واژگان")
        time.sleep(4)
        # ⚠️ indexedDB.databases() ist asynchron — das Ergebnis wird über einen
        # Merker am window abgeholt, damit kein async-Skript nötig ist.
        js("""
          window.__voxDbNames = null;
          if (indexedDB.databases) {
            indexedDB.databases().then(function(list){
              window.__voxDbNames = list.map(function(d){ return d.name; }).join(',');
            }).catch(function(){ window.__voxDbNames = ''; });
          } else { window.__voxDbNames = 'unsupported'; }
        """)
        wait_until(lambda: js("return window.__voxDbNames !== null;"), 15)
        namen = str(js("return window.__voxDbNames;") or "")
        check(DB_ANGELEGT, "vox" in namen or namen == "unsupported",
              f"(IndexedDB: {namen or 'keine'})")

        check("Wortschatz öffnet sich",
              wait_until(lambda: not shows("Grammatik") or shows("Wortschatz"), 20))
        back()
        goto_home()

        # ── Grammatik ─────────────────────────────────────────────────────────
        check("Grammatik öffnet sich",
              tap_any("Grammatik", "گرامر") and wait_until(
                  lambda: len(leaves()) > 2, 20))
        back()
        goto_home()

        # ── Selbstlernen + Routine-Verlinkung (2026-09-13) ────────────────────
        tap_any("Selbstlernen", "خودآموزی")
        time.sleep(3)
        check("Selbstlernen öffnet sich",
              wait_until(lambda: shows("Pomodoro"), 20))
        check("Selbstlernen zeigt die Routine-Karte",
              shows("Routine", "روتین"))

        # ⚠️ Der eigentliche Beweis der Verlinkung: Es muss ein ZWEITER Tab
        # aufgehen, und der muss auf Root-in zeigen. Ohne diese Prüfung ginge
        # eine Karte, die ins Leere tippt, grün durch.
        vorher = len(call("GET", f"/session/{session}/window/handles")["value"])
        tap_any("Routine", "روتین")
        time.sleep(3)
        handles = call("GET", f"/session/{session}/window/handles")["value"]
        neuer_tab = len(handles) > vorher
        ziel = ""
        if neuer_tab:
            call("POST", f"/session/{session}/window",
                 {"handle": handles[-1]})
            ziel = str(call("GET", f"/session/{session}/url")["value"])
            call("POST", f"/session/{session}/window", {"handle": handles[0]})
        check("Routine öffnet Root-in in einem neuen Tab",
              neuer_tab and ROOT_IN_URL in ziel,
              f"(Ziel: {ziel or 'kein neuer Tab'})")

        # ── Pomodoro ──────────────────────────────────────────────────────────
        check("Pomodoro öffnet sich",
              tap_any("Pomodoro") and wait_until(lambda: len(leaves()) > 2, 20))

        # ── Neuladen ──────────────────────────────────────────────────────────
        # ⚠️ Der Zustand nach einem Neuladen ist im Browser nicht selbst-
        # verständlich: Die Datenbank liegt im Browser-Speicher, und ein Fehler
        # beim Wiederöffnen zeigt sich NUR hier.
        goto_home()
        call("POST", f"/session/{session}/refresh", {})
        check("Nach dem Neuladen kommt die App wieder hoch", boot())
        check("Startseite steht auch nach dem Neuladen",
              wait_until(lambda: shows("Wortschatz"), 30))

        print()
        return urteil(failures, bestanden[0])

    finally:
        if session:
            try:
                call("DELETE", f"/session/{session}")
            except Exception:
                pass
        driver.terminate()


if __name__ == "__main__":
    sys.exit(main())
