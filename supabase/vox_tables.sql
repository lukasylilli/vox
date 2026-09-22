-- VOX — eigene Servertabellen und Zugriffsregeln (PLAN.md → فاز S, S.3)
--
-- ANWENDEN: Supabase-Projekt öffnen → SQL Editor → diese Datei einfügen →
-- ausführen. Sie ist mehrfach ausführbar (idempotent).
--
-- ⚠️ ZWEI APPS, EIN PROJEKT, GETRENNTE TABELLEN
-- VOX und Root-in teilen sich dasselbe Supabase-Projekt und damit
-- `auth.users`: Wer sich in einer der beiden Apps registriert, meldet sich in
-- der anderen mit derselben Adresse an. Die TABELLEN gehören aber je einem
-- Repo, und keines fasst die des anderen an:
--
--   Root-in  → `supabase/schema.sql`     : profiles, backups,
--                                          username_available(),
--                                          delete_own_account(),
--                                          touch_updated_at()
--   VOX      → diese Datei               : vox_backups
--   BEIDE    → zeichengleich in beiden   : touch_updated_at(),
--                                          delete_own_account() (L.1d)
--
-- Beide Dateien müssen im selben Projekt ausgeführt werden. Die Reihenfolge
-- ist egal — Abschnitt 4 und 5 legen `touch_updated_at()` und
-- `delete_own_account()` mit `create or replace` an, mit demselben Rumpf wie
-- Root-in. Wer nur VOX betreibt, braucht
-- schema.sql nicht; wer beide betreibt, spielt beide ein.
--
-- ⚠️ DAS PROJEKT IST OPEN SOURCE — jeder liest diese Datei.
-- Das ist bei Row Level Security vorgesehen: Die Regeln sind kein Geheimnis,
-- sie sind ein Mechanismus. Aber es heißt, dass sie wirklich stimmen müssen.
-- Auf Unkenntnis des Angreifers ist kein Verlass.
--
-- ⚠️ ZWEI SCHLÜSSEL, ZWEI WELTEN
--   anon / publishable → steht in der App, ist auslesbar, DARF öffentlich
--                        sein. Für ihn gelten die Regeln unten.
--   service_role       → umgeht JEDE Regel hier. Gehört ausschließlich in die
--                        Supabase-Oberfläche. Niemals in App, Repository, CI.

-- ---------------------------------------------------------------------------
-- 1. Sicherung des Lernbestands
-- ---------------------------------------------------------------------------
-- GENAU EINE Zeile je Konto — deshalb ist `user_id` der Primärschlüssel und
-- nicht nur ein Verweis. Eine Sicherung ist ein Stand, keine Historie; ohne
-- diese Einschränkung sammelten sich stillschweigend Kopien an, und niemand
-- wüsste, welche gilt.
--
-- `payload` ist die Nutzlast aus `lib/core/backup/nutzer_zustand.dart` —
-- DIESELBE Serialisierung wie Export/Import in S.2, kein zweites Format
-- (Puzzling-Prinzip: eine Quelle). Enthalten sind ausschließlich
-- NUTZERDATEN: Leitner-Fächer, Listen, Notizen, Einstellungen, eigene
-- Wörter. **Keine Wortkarten** — die stecken in der App und sind für alle
-- gleich. Deshalb bleibt eine Zeile winzig.
--
-- `schema_version` ist die Version DIESES JSON-Formats, nicht die der
-- lokalen Datenbank. Sie entscheidet, ob eine ältere App eine neuere
-- Sicherung ablehnen muss, statt sie falsch zu lesen.
--
-- ⚠️ Der Name ist bewusst `vox_backups` und nicht `backups`: `backups`
-- gehört Root-in. Zwei Apps mit unterschiedlicher Nutzlast dürfen sich
-- nicht dieselbe Tabelle teilen — die eine würde die Sicherung der anderen
-- überschreiben, weil `user_id` in beiden der Primärschlüssel ist.
create table if not exists public.vox_backups (
  user_id        uuid primary key references auth.users (id) on delete cascade,
  payload        jsonb       not null,
  schema_version integer     not null,
  device_label   text,
  updated_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 2. Zugriff, Schicht 1: wer darf die Tabelle überhaupt anfassen (grants)
-- ---------------------------------------------------------------------------
-- Die Rechte stehen hier ausdrücklich, statt sich auf die Projekt-Einstellung
-- „Automatically expose new tables" zu verlassen. Supabase empfiehlt selbst,
-- die auszuschalten — dann aber bekommt eine neue Tabelle KEINE Rechte, und
-- die App liefe in „permission denied", ohne dass man es dem SQL ansieht.
-- ⚠️ So funktioniert diese Datei in BEIDEN Einstellungen; sie hängt nicht an
-- einem Schalter in einer Weboberfläche, den niemand versioniert.
grant usage on schema public to authenticated;

-- ⚠️ NUR `authenticated`, ausdrücklich NICHT `anon`.
-- `anon` ist der Zustand vor der Anmeldung. Wer nicht angemeldet ist, hat in
-- dieser Tabelle nichts zu suchen — auch keine leere Antwort. Das ist die
-- zweite Verteidigungslinie: Selbst wenn unten eine Regel falsch wäre, käme
-- ein nicht angemeldeter Aufruf gar nicht erst bis zu ihr.
grant select, insert, update, delete on public.vox_backups to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Zugriff, Schicht 2: welche Zeilen (Row Level Security)
-- ---------------------------------------------------------------------------
-- ⚠️ OHNE DIESE ZEILEN SIEHT JEDER ANGEMELDETE NUTZER DIE DATEN ALLER ANDEREN.
-- Die Grants oben unterscheiden nur „angemeldet ja/nein"; dass jemand nur
-- SEINE Zeile sieht, macht allein RLS. Der anon-Schlüssel steht in der
-- ausgelieferten App und ist kein Schutz.
alter table public.vox_backups enable row level security;

-- Eine Regel je Vorgang statt einer „for all"-Regel: So steht jede erlaubte
-- Handlung ausdrücklich da, und ein späteres Weglassen fällt beim Lesen auf.
-- `auth.uid()` ist die Kennung aus dem mitgeschickten Token.

drop policy if exists "vox_backups_select_own" on public.vox_backups;
create policy "vox_backups_select_own" on public.vox_backups
  for select using (auth.uid() = user_id);

drop policy if exists "vox_backups_insert_own" on public.vox_backups;
create policy "vox_backups_insert_own" on public.vox_backups
  for insert with check (auth.uid() = user_id);

drop policy if exists "vox_backups_update_own" on public.vox_backups;
create policy "vox_backups_update_own" on public.vox_backups
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "vox_backups_delete_own" on public.vox_backups;
create policy "vox_backups_delete_own" on public.vox_backups
  for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 4. `updated_at` schreibt der Server, nicht die App
-- ---------------------------------------------------------------------------
-- Eine von der App gesetzte Zeit ist die Zeit einer möglicherweise falsch
-- gestellten Geräteuhr. „Zuletzt gesichert vor …" muss sich auf eine Uhr
-- stützen, die der Nutzer nicht stellen kann.
--
-- ⚠️ Rumpf ZEICHENGLEICH zu `supabase/schema.sql` in Root-in. Beide Dateien
-- legen dieselbe Funktion mit `create or replace` an; wer beide einspielt,
-- bekommt kein zweites Verhalten. Wer diese Funktion je ändert, muss sie in
-- BEIDEN Dateien ändern.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists vox_backups_touch_updated_at on public.vox_backups;
create trigger vox_backups_touch_updated_at
  before insert or update on public.vox_backups
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- 5. Konto vollständig löschen (PLAN.md → L.1d, 2026-09-22)
-- ---------------------------------------------------------------------------
-- Löscht das EIGENE Konto: den Eintrag in `auth.users` — und über
-- `on delete cascade` die Zeilen BEIDER Apps: `vox_backups` (oben) und
-- Root-ins `profiles`/`backups`. Aufgerufen von `AuthService.deleteAccount()`.
-- Lukas hat entschieden: ein Konto, ein Löschen, für beide Apps (L.1d).
--
-- ⚠️ Rumpf, `revoke` und `grant` ZEICHENGLEICH zu `supabase/schema.sql`
-- (Root-in, Abschnitt 6). Wie bei `touch_updated_at()`: Wer beide Dateien
-- einspielt, bekommt kein zweites Verhalten; wer nur VOX betreibt, hat die
-- Funktion trotzdem. Änderung immer in BEIDEN Dateien.
--
-- WARUM EINE FUNKTION UND KEINE EDGE FUNCTION
-- Der anon-Schlüssel darf `auth.users` nicht anfassen, also braucht es einen
-- Aufruf mit erhöhten Rechten. Eine Edge Function bräuchte eine eigene
-- Bereitstellung (Supabase-CLI plus Zugangs-Token als Secret) — ein zweiter
-- Weg auf den Server neben dem SQL-Editor.
--
-- ⚠️ `security definer` IST HIER DER GANZE PUNKT — UND DIE GANZE GEFAHR.
-- Die Funktion läuft mit den Rechten ihres Eigentümers, der `auth.users`
-- löschen darf; der Aufrufer darf das nicht. Deshalb:
--   - Sie löscht AUSSCHLIESSLICH `auth.uid()`. Es gibt KEINEN Parameter, über
--     den jemand eine fremde Kennung hineinreichen könnte. Wer hier je einen
--     hinzufügt, baut „jeder löscht jeden".
--   - Ohne Anmeldung ist `auth.uid()` leer → sie bricht ab. Zusätzlich ist
--     die Ausführung für `anon` und `PUBLIC` gar nicht erst freigegeben
--     (Supabase gibt neuen Funktionen sonst von selbst `anon`-Rechte).
--   - `set search_path = ''` und voll qualifizierte Namen: Eine security-
--     definer-Funktion mit offenem Suchpfad lässt sich über ein gleichnamiges
--     Objekt in einem anderen Schema umlenken.
create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'nicht angemeldet' using errcode = '42501';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_own_account() from public, anon;
grant execute on function public.delete_own_account() to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Gegenprobe — nach dem Anwenden ausführen
-- ---------------------------------------------------------------------------
-- Muss `vox_backups` mit rowsecurity = true zeigen. Steht dort false, ist die
-- Tabelle offen, und der Rest dieser Datei ist wirkungslos.
--
--   select tablename, rowsecurity
--     from pg_tables
--    where schemaname = 'public';
--
-- Und die Rechte aus Abschnitt 2 — erwartet werden Zeilen für
-- `authenticated`, aber KEINE für `anon`:
--
--   select grantee, table_name, privilege_type
--     from information_schema.role_table_grants
--    where table_schema = 'public'
--      and table_name   = 'vox_backups'
--      and grantee in ('anon', 'authenticated');
--
-- ⚠️ Die eigentliche Probe läuft NICHT hier, sondern von außen mit dem
-- anon-Schlüssel: ohne Anmeldung lesen (muss leer bleiben) und als Konto A
-- die Zeile von Konto B abfragen (muss leer bleiben). Ein `select` im
-- SQL-Editor läuft mit erhöhten Rechten und umgeht die Regeln — er beweist
-- an dieser Stelle also gar nichts.
--
-- Und Abschnitt 5 — erwartet: `authenticated` ja, `anon`/`PUBLIC` NEIN:
--
--   select grantee, privilege_type
--     from information_schema.routine_privileges
--    where routine_schema = 'public'
--      and routine_name   = 'delete_own_account';
