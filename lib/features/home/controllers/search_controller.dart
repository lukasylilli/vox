// FILE: lib/features/home/controllers/search_controller.dart
// PHASE: G8 (2026-11-16) — globale Suche über die ganze App
// DEPS: such_index.dart (Regeln), die Provider aller Decks, Grammatik-Katalog
// PURPOSE: Trägt alles zusammen, was die globale Suche außerhalb der Wörter
//          findet: Grammatik-Katalog (84 Lektionen + Themen), alle Decks aus
//          Auswendiglernen und die vom Nutzer importierten Inhalte (alte
//          Grammatik-Lektionen, Redewendungen) aus der Datenbank.
//
// Vorher (bis 2026-11-16) suchte die globale Suche Grammatik und Phrasen nur
// in zwei Datenbank-Tabellen, die bei normalen Nutzern LEER sind (nur der
// Import füllt sie) — Lektionen und Decks waren gar nicht auffindbar.
//
// Die Wörter kommen nicht von hier: der Screen nimmt sie aus derselben
// Quelle wie «Alle Wörter» (wortschatzBasisLesen → wortschatzZeilen), damit
// Reihenfolge, gebeugte Formen und Zeile überall gleich sind.
//
// ⚠️ Neues Deck in Auswendiglernen ⇒ hier einen Abschnitt und in
//    such_index.dart einen [SuchBereich] ergänzen;
//    test/globale_suche_test.dart prüft, dass jeder Bereich Einträge hat und
//    jede Route zu einer Seite führt.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/feature_flags.dart';
import '../../auswendiglernen/controllers/auswendiglernen_controller.dart'
    show memorizeCategories;
import '../../dativ_verben/controllers/dativ_verben_controller.dart';
import '../../grammatik/controllers/grammar_catalog_controller.dart';
import '../../konnektoren/controllers/konnektoren_controller.dart';
import '../../modalverben/controllers/modalverben_controller.dart';
import '../../nvv/controllers/nvv_controller.dart';
import '../../praepositionen/controllers/praepositionen_controller.dart';
import '../../redemittel/controllers/redemittel_controller.dart';
import '../../redemittel/models/redemittel_item.dart';
import '../../reflexiv_verben/controllers/reflexiv_controller.dart';
import '../../trennbar_verben/controllers/trennbar_controller.dart';
import '../../unregelm_verben/controllers/unregelm_controller.dart';
import '../../verb_praep/controllers/verb_praep_controller.dart';
import '../../wortschatz/controllers/word_controller.dart' show databaseProvider;
import '../data/such_index.dart';

/// Ist der Bereich freigeschaltet? Ein Deck, das «به‌زودی» oder verborgen
/// ist, wird nicht durchsucht.
bool suchBereichAktiv(SuchBereich b) =>
    b.flag.isEmpty || FeatureFlags.isLive(b.flag);

List<SuchEintrag> _redemittel(
  SuchBereich bereich,
  List<RedemittelItem> liste,
  String Function(int id) route,
) =>
    [
      for (final r in liste)
        SuchEintrag(
          bereich: bereich,
          titel: r.phraseDe,
          fa: r.phraseFa,
          en: r.phraseEn,
          route: route(r.id),
          niveau: r.cefrLevel,
        ),
    ];

/// Alle durchsuchbaren Einträge außer den Wörtern. Einmal geladen, bleibt im
/// Speicher (~2.500 kurze Einträge); die Suche selbst ist [suchGruppen].
final suchIndexProvider = FutureProvider<List<SuchEintrag>>((ref) async {
  final eintraege = <SuchEintrag>[];
  Future<void> wenn(
      SuchBereich b, Future<List<SuchEintrag>> Function() laden) async {
    if (suchBereichAktiv(b)) eintraege.addAll(await laden());
  }

  // ── Grammatik: der Katalog (Lektionen + Themen), nur was es schon gibt ──
  final katalog = await ref.watch(grammatikKatalogProvider.future);
  for (final e in katalog.eintraege) {
    final route = e.route;
    if (route == null) continue;
    eintraege.add(SuchEintrag(
      bereich: SuchBereich.grammatik,
      titel: e.de,
      fa: e.fa,
      en: e.en,
      route: route,
      niveau: e.niveaus.map((n) => n.toUpperCase()).join(' · '),
    ));
  }
  // Vom Nutzer importierte Lektionen (Datenbank; sonst leer).
  final db = ref.watch(databaseProvider);
  for (final l in await db.select(db.grammarLessons).get()) {
    eintraege.add(SuchEintrag(
      bereich: SuchBereich.grammatik,
      titel: l.title,
      fa: '',
      en: '',
      route: '/grammatik/lesson/${l.id}',
      niveau: l.level.toUpperCase(),
    ));
  }

  // ── Decks, in der Reihenfolge von Auswendiglernen ───────────────────────
  await wenn(SuchBereich.konnektoren, () async => [
        for (final k in await ref.watch(konnektorenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.konnektoren,
            titel: k.connector,
            fa: k.meaningFa,
            en: k.meaningEn,
            route: AppRoutes.konnektorenDetail(k.id),
            niveau: k.cefrLevel,
          ),
      ]);
  await wenn(SuchBereich.dativVerben, () async => [
        for (final v in await ref.watch(dativVerbenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.dativVerben,
            titel: v.verbInfinitive,
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.dativVerbenDetail(v.id),
            niveau: v.cefrLevel,
            formen: [
              v.principalParts.praesens3sg,
              v.principalParts.praeteritum,
              v.principalParts.perfekt,
            ],
          ),
      ]);
  await wenn(SuchBereich.nvv, () async => [
        for (final p in await ref.watch(nvvPhrasesProvider.future))
          SuchEintrag(
            bereich: SuchBereich.nvv,
            titel: p.phraseDe,
            fa: p.meaningFa,
            en: p.meaningEn,
            route: AppRoutes.nvvDetail(p.id),
            niveau: p.cefrLevel,
            formen: [p.synonymDe],
          ),
      ]);
  await wenn(SuchBereich.praepositionen, () async => [
        for (final c in await ref.watch(praepClusterProvider.future))
          SuchEintrag(
            bereich: SuchBereich.praepositionen,
            titel: c.vollform,
            fa: c.meaningFa,
            en: c.meaningEn,
            route: AppRoutes.praepositonenDetail(c.id),
            niveau: c.cefrLevel,
          ),
      ]);
  await wenn(SuchBereich.unregelmVerben, () async => [
        for (final v in await ref.watch(unregelVerbenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.unregelmVerben,
            titel: v.verbInfinitive,
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.unregelVerbenDetail(v.id),
            niveau: v.cefrLevel,
            formen: [
              v.principalParts.praesens3sg,
              v.principalParts.praeteritum,
              v.principalParts.partizipIi,
            ],
          ),
      ]);
  await wenn(SuchBereich.trennbarVerben, () async => [
        for (final v in await ref.watch(trennbarVerbenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.trennbarVerben,
            titel: v.verbInfinitive,
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.trennbarDetail(v.id),
            niveau: v.cefrLevel,
            formen: [
              v.principalParts.praesens3sg,
              v.principalParts.praeteritum,
              v.principalParts.perfekt,
            ],
          ),
      ]);
  await wenn(SuchBereich.reflexivVerben, () async => [
        for (final v in await ref.watch(reflexivVerbenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.reflexivVerben,
            titel: v.verbInfinitive,
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.reflexivDetail(v.id),
            niveau: v.cefrLevel,
            formen: [
              v.principalParts.praesens3sg,
              v.principalParts.praeteritum,
              v.principalParts.perfekt,
            ],
          ),
      ]);
  await wenn(SuchBereich.verbPraep, () async => [
        for (final v in await ref.watch(verbPraepProvider.future))
          SuchEintrag(
            bereich: SuchBereich.verbPraep,
            titel: '${v.displayVerb} ${v.preposition}',
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.verbPraepDetail(v.id),
            niveau: v.cefrLevel,
            formen: [
              v.woCompound,
              v.principalParts.praesens3sg,
              v.principalParts.praeteritum,
              v.principalParts.partizipIi,
            ],
          ),
      ]);
  await wenn(SuchBereich.modalverben, () async => [
        for (final v in await ref.watch(modalVerbenProvider.future))
          SuchEintrag(
            bereich: SuchBereich.modalverben,
            titel: v.infinitive,
            fa: v.meaningFa,
            en: v.meaningEn,
            route: AppRoutes.modalverbenDetail(v.id),
            formen: [
              ...v.praesens.values,
              ...v.praeteritum.values,
              v.partizip2,
            ],
          ),
      ]);
  await wenn(
      SuchBereich.redemittelGoetheB2,
      () async => _redemittel(
          SuchBereich.redemittelGoetheB2,
          await ref.watch(redemittelGoetheB2Provider.future),
          AppRoutes.redemittelGoetheB2Detail));
  await wenn(
      SuchBereich.redemittelOesdB2,
      () async => _redemittel(
          SuchBereich.redemittelOesdB2,
          await ref.watch(redemittelOesdB2Provider.future),
          AppRoutes.redemittelOesdB2Detail));
  await wenn(
      SuchBereich.redemittelOesdC1,
      () async => _redemittel(
          SuchBereich.redemittelOesdC1,
          await ref.watch(redemittelOesdC1Provider.future),
          AppRoutes.redemittelOesdC1Detail));
  await wenn(
      SuchBereich.redemittel1010,
      () async => _redemittel(
          SuchBereich.redemittel1010,
          await ref.watch(redemittel1010Provider.future),
          AppRoutes.redemittel1010Detail));

  // ── Auswendiglernen: vom Nutzer importierte Phrasen (Datenbank) ─────────
  for (final p in await db.select(db.memorizeItems).get()) {
    final nr = memorizeCategories.indexOf(p.category);
    eintraege.add(SuchEintrag(
      bereich: SuchBereich.auswendiglernen,
      titel: p.phrase,
      fa: p.meaning,
      en: p.meaningEn ?? p.meaning,
      route: nr < 0
          ? AppRoutes.auswendiglernen
          : '${AppRoutes.auswendiglernen}/$nr',
      niveau: p.level ?? '',
    ));
  }
  return eintraege;
});

/// Treffer der globalen Suche außerhalb der Wörter, gruppiert
/// ([suchGruppen]). Leer, solange die Suche zu kurz ist.
final suchGruppenProvider = FutureProvider.family<
    Map<SuchBereich, List<SuchEintrag>>, String>((ref, query) async {
  if (suchNormal(query).length < suchMindestLaenge) return const {};
  return suchGruppen(await ref.watch(suchIndexProvider.future), query);
});
