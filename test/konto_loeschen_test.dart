// FILE: test/konto_loeschen_test.dart
// PHASE: L.1d — Konto löschen (2026-09-22)
// PURPOSE: Der Knopf «حذف حساب» auf der Profil-Seite:
//          · fragt vorher und sagt dabei, dass Root-in mitgelöscht wird
//          · Abbrechen löscht nichts
//          · deleted     → Meldung «gelöscht»
//          · unavailable → eigene VOX-Sicherung löschen + abmelden, Meldung «teilweise»
//          · failed      → nichts gelöscht, weiter angemeldet
//
// Server, Konto und Abgleich sind ersetzt — kein Netzaufruf.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/backup/cloud_abgleich.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/core/services/auth_service.dart';
import 'package:vox/core/services/cloud_ablage_supabase.dart';
import 'package:vox/features/more/controllers/konto_abgleich.dart';
import 'package:vox/features/more/widgets/profil_konto_karte.dart';

const _konto = AuthAccount(id: 'u1', email: 'a@b.de');

class _Auth extends AuthService {
  _Auth(this.ausgang);

  final AccountDeletion ausgang;
  int loeschAufrufe = 0;
  int abmeldungen = 0;

  @override
  AuthAccount? get currentAccount => _konto;

  @override
  Future<AccountDeletion> deleteAccount() async {
    loeschAufrufe++;
    return ausgang;
  }

  @override
  Future<void> signOut() async {
    abmeldungen++;
  }
}

class _Ablage implements CloudAblage {
  int loeschungen = 0;

  @override
  bool get verfuegbar => true;

  @override
  Future<CloudStand?> holen() async => null;

  @override
  Future<void> ablegen(Map<String, dynamic> payload, int version) async {}

  @override
  Future<DateTime?> zuletzt() async => null;

  @override
  Future<void> loeschen() async {
    loeschungen++;
  }
}

/// Kein Timer, kein Abgleich — die Karte braucht nur einen Stand.
class _StillerAbgleich extends KontoAbgleich {
  @override
  KontoAbgleichStand build() => const KontoAbgleichStand();
}

Future<void> _zeige(WidgetTester tester, _Auth auth, _Ablage ablage) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      cloudAblageProvider.overrideWithValue(ablage),
      authAccountProvider.overrideWith((ref) => Stream.value(_konto)),
      kontoAbgleichProvider.overrideWith(_StillerAbgleich.new),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(
        body: SingleChildScrollView(child: ProfilKontoKarte()),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _tippeLoeschen(WidgetTester tester) async {
  final knopf = find.byKey(const ValueKey('konto_loeschen'));
  await tester.ensureVisible(knopf);
  await tester.pumpAndSettle();
  await tester.tap(knopf);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Knopf erscheint im angemeldeten Zustand', (tester) async {
    await _zeige(tester, _Auth(AccountDeletion.deleted), _Ablage());
    expect(find.byKey(const ValueKey('konto_loeschen')), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('Dialog nennt Root-in; Abbrechen löscht nichts', (tester) async {
    final auth = _Auth(AccountDeletion.deleted);
    await _zeige(tester, auth, _Ablage());
    await _tippeLoeschen(tester);

    expect(find.text('Delete account for good?'), findsOneWidget);
    expect(find.textContaining('Root-in'), findsWidgets);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(auth.loeschAufrufe, 0);
    expect(auth.abmeldungen, 0);
  });

  testWidgets('deleted: Konto gelöscht, Meldung', (tester) async {
    final auth = _Auth(AccountDeletion.deleted);
    final ablage = _Ablage();
    await _zeige(tester, auth, ablage);
    await _tippeLoeschen(tester);
    await tester.tap(find.text('Delete for good'));
    await tester.pumpAndSettle();

    expect(auth.loeschAufrufe, 1);
    // Die Ablage wird nur im Notfall angefasst — hier löscht der Server.
    expect(ablage.loeschungen, 0);
    expect(find.textContaining('Your account has been deleted'), findsOneWidget);
  });

  testWidgets('unavailable: VOX-Sicherung weg, abgemeldet, ehrliche Meldung',
      (tester) async {
    final auth = _Auth(AccountDeletion.unavailable);
    final ablage = _Ablage();
    await _zeige(tester, auth, ablage);
    await _tippeLoeschen(tester);
    await tester.tap(find.text('Delete for good'));
    await tester.pumpAndSettle();

    expect(ablage.loeschungen, 1);
    expect(auth.abmeldungen, 1);
    expect(find.textContaining('could not be removed'), findsOneWidget);
  });

  testWidgets('failed: nichts gelöscht, nicht abgemeldet', (tester) async {
    final auth = _Auth(AccountDeletion.failed);
    final ablage = _Ablage();
    await _zeige(tester, auth, ablage);
    await _tippeLoeschen(tester);
    await tester.tap(find.text('Delete for good'));
    await tester.pumpAndSettle();

    expect(ablage.loeschungen, 0);
    expect(auth.abmeldungen, 0);
    expect(find.textContaining('Nothing was deleted'), findsOneWidget);
  });

  test('ohne Server meldet deleteAccount failed statt zu werfen', () async {
    expect(await const AuthService().deleteAccount(), AccountDeletion.failed);
  });
}
