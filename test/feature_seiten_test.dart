// FILE: test/feature_seiten_test.dart
// PURPOSE: Audit 2026-11-11, Paket 7 — bis dahin hatten 15 Bereiche der App
//          keinen einzigen Test. Zwei Dinge werden hier für jeden geprüft:
//
//          1. DATEN: jede Datendatei (assets/data/*.json) lässt sich laden
//             und in die Modelle lesen und ist nicht leer. Ein Tippfehler in
//             einer JSON-Datei macht sonst erst beim Nutzer die Seite leer.
//          2. SEITEN: jede Einstiegsseite baut sich mit den echten Daten ohne
//             Ausnahme auf (Farsi und Englisch).
//
//          rootBundle läuft innerhalb von testWidgets (FakeAsync) nie sauber
//          zu Ende (siehe test/helpers/wortschatz_overrides.dart) — deshalb
//          werden die Daten EINMAL in setUpAll geladen und den Seiten als
//          feste Werte übergeben.
//
//          Nicht hier: Lesen und Hören (brauchen die drift-Datenbank) und die
//          Quiz-/Detailseiten (brauchen einen ausgewählten Eintrag).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vox/core/l10n/app_l10n.dart';
import 'package:vox/features/dativ_verben/controllers/dativ_verben_controller.dart';
import 'package:vox/features/dativ_verben/screens/dativ_grammar_screen.dart';
import 'package:vox/features/dativ_verben/screens/dativ_verben_list_screen.dart';
import 'package:vox/features/fragen/screens/fragen_screen.dart';
import 'package:vox/features/konnektoren/controllers/konnektoren_controller.dart';
import 'package:vox/features/konnektoren/screens/konnektoren_grammar_screen.dart';
import 'package:vox/features/konnektoren/screens/konnektoren_home_screen.dart';
import 'package:vox/features/modalverben/controllers/modalverben_controller.dart';
import 'package:vox/features/modalverben/screens/modalverben_list_screen.dart';
import 'package:vox/features/nvv/controllers/nvv_controller.dart';
import 'package:vox/features/nvv/screens/nvv_grammar_screen.dart';
import 'package:vox/features/nvv/screens/nvv_home_screen.dart';
import 'package:vox/features/redemittel/controllers/redemittel_controller.dart';
import 'package:vox/features/redemittel/screens/redemittel_1010_grammar_screen.dart';
import 'package:vox/features/redemittel/screens/redemittel_1010_list_screen.dart';
import 'package:vox/features/reflexiv_verben/controllers/reflexiv_controller.dart';
import 'package:vox/features/reflexiv_verben/screens/reflexiv_grammar_screen.dart';
import 'package:vox/features/reflexiv_verben/screens/reflexiv_list_screen.dart';
import 'package:vox/features/schreiben/screens/schreiben_home_screen.dart';
import 'package:vox/features/sozialmedien/screens/sozialmedien_screen.dart';
import 'package:vox/features/sprechen/screens/sprechen_home_screen.dart';
import 'package:vox/features/trennbar_verben/controllers/trennbar_controller.dart';
import 'package:vox/features/trennbar_verben/screens/trennbar_grammar_screen.dart';
import 'package:vox/features/trennbar_verben/screens/trennbar_list_screen.dart';
import 'package:vox/features/unregelm_verben/controllers/unregelm_controller.dart';
import 'package:vox/features/unregelm_verben/screens/unregelm_grammar_screen.dart';
import 'package:vox/features/unregelm_verben/screens/unregelm_list_screen.dart';
import 'package:vox/features/verb_praep/controllers/verb_praep_controller.dart';
import 'package:vox/features/verb_praep/screens/verb_praep_grammar_screen.dart';
import 'package:vox/features/verb_praep/screens/verb_praep_list_screen.dart';
import 'package:vox/features/vokabular/controllers/vokabular_controller.dart';

/// Geladene Werte je Datenquelle (Name ⇒ Anzahl) und die festen Overrides.
final _anzahl = <String, int>{};
final _fest = <Override>[];

Future<void> _laden<T>(
  ProviderContainer quelle,
  String name,
  FutureProvider<T> provider,
) async {
  final wert = await quelle.read(provider.future);
  _anzahl[name] = switch (wert) {
    final List<dynamic> l => l.length,
    final Map<dynamic, dynamic> m => m.length,
    _ => -1,
  };
  _fest.add(provider.overrideWith((ref) => wert));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final quelle = ProviderContainer();
    await _laden(quelle, 'konnektoren', konnektorenProvider);
    await _laden(quelle, 'konnektoren_rich', konnektorenRichProvider);
    await _laden(quelle, 'konnektoren_grammar', konnektorenGrammarProvider);
    await _laden(quelle, 'dativ_verben', dativVerbenProvider);
    await _laden(quelle, 'dativ_grammar', dativGrammarProvider);
    await _laden(quelle, 'reflexiv_verben', reflexivVerbenProvider);
    await _laden(quelle, 'reflexiv_grammar', reflexivGrammarProvider);
    await _laden(quelle, 'trennbar_verben', trennbarVerbenProvider);
    await _laden(quelle, 'trennbar_grammar', trennbarGrammarProvider);
    await _laden(quelle, 'unregelm_verben', unregelVerbenProvider);
    await _laden(quelle, 'unregelm_grammar', unregelVerbenGrammarProvider);
    await _laden(quelle, 'verb_praep', verbPraepProvider);
    await _laden(quelle, 'verb_praep_grammar', verbPraepGrammarProvider);
    await _laden(quelle, 'modalverben', modalVerbenProvider);
    await _laden(quelle, 'nvv', nvvPhrasesProvider);
    await _laden(quelle, 'redemittel_goethe_b2', redemittelGoetheB2Provider);
    await _laden(quelle, 'redemittel_oesd_b2', redemittelOesdB2Provider);
    await _laden(quelle, 'redemittel_oesd_c1', redemittelOesdC1Provider);
    await _laden(quelle, 'redemittel_1010', redemittel1010Provider);
    quelle.dispose();
    // Der Vokabel-Index wird erst beim Bauen erzeugt — für die Seiten leer.
    _fest.add(vokabIndexByIdProvider
        .overrideWith((ref) => <String, Map<String, dynamic>>{}));
  });

  group('Daten — jede Datei lädt und ist nicht leer', () {
    for (final name in const [
      'konnektoren',
      'konnektoren_rich',
      'konnektoren_grammar',
      'dativ_verben',
      'dativ_grammar',
      'reflexiv_verben',
      'reflexiv_grammar',
      'trennbar_verben',
      'trennbar_grammar',
      'unregelm_verben',
      'unregelm_grammar',
      'verb_praep',
      'verb_praep_grammar',
      'modalverben',
      'nvv',
      'redemittel_goethe_b2',
      'redemittel_oesd_b2',
      'redemittel_oesd_c1',
      'redemittel_1010',
    ]) {
      test(name, () {
        expect(_anzahl[name], isNotNull, reason: '$name wurde nicht geladen');
        expect(_anzahl[name], greaterThan(0), reason: '$name ist leer');
      });
    }
  });

  group('Seiten — bauen sich ohne Ausnahme auf', () {
    final seiten = <String, Widget Function()>{
      'Konnektoren': () => const KonnektorenHomeScreen(),
      'Konnektoren · Grammatik': () => const KonnektorenGrammarScreen(),
      'Dativ-Verben': () => const DativVerbenListScreen(),
      'Dativ-Verben · Grammatik': () => const DativGrammarScreen(),
      'NVV': () => const NvvHomeScreen(),
      'NVV · Grammatik': () => const NvvGrammarScreen(),
      'Reflexive Verben': () => const ReflexivListScreen(),
      'Reflexive Verben · Grammatik': () => const ReflexivGrammarScreen(),
      'Trennbare Verben': () => const TrennbarListScreen(),
      'Trennbare Verben · Grammatik': () => const TrennbarGrammarScreen(),
      'Verb + Präposition': () => const VerbPraepListScreen(),
      'Verb + Präposition · Grammatik': () => const VerbPraepGrammarScreen(),
      'Redemittel 10×10': () => const Redemittel1010ListScreen(),
      'Redemittel 10×10 · Grammatik': () =>
          const Redemittel1010GrammarScreen(),
      'Modalverben': () => const ModalverbenListScreen(),
      'Unregelmäßige Verben': () => const UnregelmListScreen(),
      'Unregelmäßige Verben · Grammatik': () => const UnregelmGrammarScreen(),
      'Sprechen': () => const SprechenHomeScreen(),
      'Schreiben': () => const SchreibenHomeScreen(),
      'Fragen': () => const FragenScreen(),
      'Soziale Medien': () => const SozialmedienScreen(),
    };

    for (final eintrag in seiten.entries) {
      for (final sprache in const ['fa', 'en']) {
        testWidgets('${eintrag.key} ($sprache)', (tester) async {
          SharedPreferences.setMockInitialValues({});
          // Hohe Fläche: lange Listen sollen nicht am Testfenster scheitern.
          tester.view.physicalSize = const Size(1200, 2400);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(ProviderScope(
            overrides: _fest,
            child: MaterialApp(
              locale: Locale(sprache),
              supportedLocales: AppL10n.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: eintrag.value(),
            ),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(tester.takeException(), isNull);
          expect(find.byType(Scaffold), findsWidgets);
          expect(find.byType(ErrorWidget), findsNothing);
        });
      }
    }
  });
}
