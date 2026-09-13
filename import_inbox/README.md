# Import-Inbox (فاز V, Stufe ۵)

Workflow für neue Wörter (SUPER-PROMPT **v3.0**, `old files Lukasalmani/Wort prompt`):

1. 1–10 Wörter durch den Konverter-Prompt schicken → JSON-**Array** kopieren.
2. Als Datei hier ablegen, z. B. `batch_2026-07-14_a.json` (Code-Fences egal — der Importer entfernt sie).
3. Ausführen:
   ```
   dart run tool/vokabular_import.dart              # alle import_inbox/*.json
   dart run tool/vokabular_import.dart --dry-run    # nur prüfen, nichts schreiben
   dart run tool/vokabular_import.dart --update     # vorhandene Wörter überschreiben
   ```
4. Bericht lesen: **Fehler** = Karte wurde NICHT geschrieben (im Prompt neu generieren);
   **Warnungen** = automatisch repariert (falsche `id`, `perfekt`/`genitiv` entfernt, `box`→1, `id_ref` korrigiert).
5. Erfolgreiche Wörter liegen als `assets/vocab/<wortart>/<id>.json` — Duplikate werden übersprungen (idempotent, erneutes Ausführen ist harmlos).

Verarbeitete Batch-Dateien können danach gelöscht werden — die Wort-Dateien in `assets/vocab/` sind die Quelle der Wahrheit.
