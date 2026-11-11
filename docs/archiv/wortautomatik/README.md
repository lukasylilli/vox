# Archiv — automatische Worterzeugung über die API (Phase A)

Stillgelegt am 2026-11-11 (Audit Paket 5, Entscheidung Lukas 2026-11-10).

Karten entstehen heute im Chat (Ablauf: `docs/WORTROUTINE.md`), nicht mehr über
die API. Diese Dateien liegen nur noch zum Nachlesen hier und laufen nicht mehr:

- `generate_words.py` — rief die Anthropic-API mit dem Wort-Prompt auf
- `backlog.py` — «nächste Wörter» (ersetzt durch `tool/naechste_woerter.dart`)
- `sync_backlog.py` — setzte ✓ in den Wortlisten (kannte `wortartKorrektur` nicht)
- `vokabular-autofill.yml` — GitHub-Workflow dazu (liegt außerhalb von
  `.github/workflows/` und wird deshalb nicht mehr ausgeführt)

Weiter in Benutzung: `tool/vokabular_import.dart` und `import_inbox/`.
Wiederbeleben nur mit Entscheidung von Lukas: Dateien zurückverschieben und
zuerst an `tool/naechste_woerter.dart` angleichen.
