// FILE: lib/core/router/app_router.dart
// DEPS: app_routes.dart + all screen files
// PURPOSE: GoRouter — all app routes. Replace PlaceholderSectionScreen per phase.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/categories/screens/category_detail_screen.dart';
import '../../features/categories/screens/category_list_screen.dart';
import '../../features/grammatik/screens/grammar_exercise_screen.dart';
import '../../features/grammatik/screens/grammar_quiz_screen.dart';
import '../../features/grammatik/screens/grammatik_home_screen.dart';
import '../../features/grammatik/screens/grammatik_katalog_screen.dart';
import '../../features/grammatik/screens/grammatik_lektion_screen.dart';
import '../../features/grammatik/screens/grammatik_niveautest_screen.dart';
import '../../features/grammatik/screens/grammatik_uebung_screen.dart';
import '../../features/grammatik/screens/lesson_detail_screen.dart';
import '../../features/grammatik/screens/level_lessons_screen.dart';
import '../../features/leitner/screens/leitner_home_screen.dart';
import '../../features/auswendiglernen/screens/auswendiglernen_home_screen.dart';
import '../../features/pruefungen/screens/exam_simulation_screen.dart';
import '../../features/pruefungen/screens/exam_type_screen.dart';
import '../../features/pruefungen/screens/pruefungen_home_screen.dart';
import '../../features/selbstlernen/screens/leitfaden_screen.dart';
import '../../features/selbstlernen/screens/pomodoro_screen.dart';
import '../../features/selbstlernen/screens/selbstlernen_home_screen.dart';
import '../../features/selbstlernen/screens/vorlagen_screen.dart';
import '../../features/fragen/screens/fragen_screen.dart';
import '../../features/more/screens/more_home_screen.dart';
import '../../features/more/screens/profil_screen.dart';
import '../../features/more/screens/settings_screen.dart';
import '../../features/more/screens/privacy_policy_screen.dart';
import '../../features/sozialmedien/screens/sozialmedien_screen.dart';
import '../../features/home/screens/search_results_screen.dart';
import '../../features/more/screens/import_screen.dart';
import '../../features/sprechen/screens/sprechen_home_screen.dart';
import '../../features/schreiben/screens/schreiben_home_screen.dart';
import '../../features/auswendiglernen/screens/category_items_screen.dart';
import '../../features/auswendiglernen/screens/cloze_practice_screen.dart';
import '../../features/auswendiglernen/screens/memorize_card_screen.dart';
import '../../features/hoeren/screens/hoeren_home_screen.dart';
import '../../features/hoeren/screens/hoeren_quiz_screen.dart';
import '../../features/hoeren/screens/karaoke_screen.dart';
import '../../features/hoeren/screens/level_audio_list_screen.dart';
import '../../features/hoeren/screens/shadowing_screen.dart';
import '../../features/lesen/screens/lesen_home_screen.dart';
import '../../features/lesen/screens/level_texts_screen.dart';
import '../../features/lesen/screens/news_screen.dart';
import '../../features/lesen/screens/text_reader_screen.dart';
import '../../features/leitner/screens/leitner_review_screen.dart';
import '../../features/leitner/screens/leitner_stats_screen.dart';
import '../../features/wortschatz/screens/add_word_screen.dart';
import '../../features/wortschatz/screens/book_list_screen.dart';
import '../../features/wortschatz/screens/book_words_screen.dart';
import '../../features/wortschatz/screens/level_words_screen.dart';
import '../../features/wortschatz/screens/wortschatz_list_screen.dart';
import '../../features/wortschatz/screens/type_words_screen.dart';
import '../../features/wortschatz/screens/word_detail_screen.dart';
import '../../features/wortschatz/screens/wortschatz_home_screen.dart';
import '../../features/konnektoren/models/konnektor_rich.dart';
import '../../features/konnektoren/screens/konnektor_detail_screen.dart';
import '../../features/konnektoren/screens/konnektoren_grammar_screen.dart';
import '../../features/konnektoren/screens/konnektoren_home_screen.dart';
import '../../features/konnektoren/screens/konnektoren_quiz_screen.dart';
import '../../features/dativ_verben/screens/dativ_verben_list_screen.dart';
import '../../features/dativ_verben/screens/dativ_verben_detail_screen.dart';
import '../../features/dativ_verben/screens/dativ_verben_quiz_screen.dart';
import '../../features/dativ_verben/screens/dativ_grammar_screen.dart';
import '../../features/dativ_verben/models/dativ_verb.dart';
import '../../features/dativ_verben/controllers/dativ_verben_controller.dart';
import '../../features/konnektoren/controllers/konnektoren_controller.dart';
import '../../features/nvv/screens/nvv_home_screen.dart';
import '../../features/nvv/screens/nvv_detail_screen.dart';
import '../../features/nvv/screens/nvv_quiz_screen.dart';
import '../../features/nvv/screens/nvv_grammar_screen.dart';
import '../../features/nvv/models/nvv_phrase.dart';
import '../../features/nvv/controllers/nvv_controller.dart';
import '../../features/praepositionen/screens/praepositionen_home_screen.dart';
import '../../features/praepositionen/screens/praep_cluster_detail_screen.dart';
import '../../features/praepositionen/screens/praepositionen_quiz_screen.dart';
import '../../features/praepositionen/screens/praepositionen_grammar_screen.dart';
import '../../features/praepositionen/models/praep_cluster.dart';
import '../../features/praepositionen/controllers/praepositionen_controller.dart';
import '../../features/reflexiv_verben/screens/reflexiv_list_screen.dart';
import '../../features/reflexiv_verben/screens/reflexiv_detail_screen.dart';
import '../../features/reflexiv_verben/screens/reflexiv_quiz_screen.dart';
import '../../features/reflexiv_verben/screens/reflexiv_grammar_screen.dart';
import '../../features/reflexiv_verben/models/reflexiv_verb.dart';
import '../../features/reflexiv_verben/controllers/reflexiv_controller.dart';
import '../../features/trennbar_verben/screens/trennbar_list_screen.dart';
import '../../features/trennbar_verben/screens/trennbar_detail_screen.dart';
import '../../features/trennbar_verben/screens/trennbar_quiz_screen.dart';
import '../../features/trennbar_verben/screens/trennbar_grammar_screen.dart';
import '../../features/trennbar_verben/models/trennbar_verb.dart';
import '../../features/trennbar_verben/controllers/trennbar_controller.dart';
import '../../features/verb_praep/screens/verb_praep_list_screen.dart';
import '../../features/verb_praep/screens/verb_praep_detail_screen.dart';
import '../../features/verb_praep/screens/verb_praep_quiz_screen.dart';
import '../../features/verb_praep/screens/verb_praep_grammar_screen.dart';
import '../../features/verb_praep/models/verb_praep.dart';
import '../../features/verb_praep/controllers/verb_praep_controller.dart';
import '../../features/unregelm_verben/screens/unregelm_list_screen.dart';
import '../../features/unregelm_verben/screens/unregelm_detail_screen.dart';
import '../../features/unregelm_verben/screens/unregelm_quiz_screen.dart';
import '../../features/unregelm_verben/screens/unregelm_grammar_screen.dart';
import '../../features/unregelm_verben/models/unregelm_verb.dart';
import '../../features/unregelm_verben/controllers/unregelm_controller.dart';
import '../../features/redemittel/screens/redemittel_1010_list_screen.dart';
import '../../features/redemittel/screens/redemittel_1010_detail_screen.dart';
import '../../features/redemittel/screens/redemittel_1010_quiz_screen.dart';
import '../../features/redemittel/screens/redemittel_1010_grammar_screen.dart';
import '../../features/redemittel/screens/redemittel_exam_list_screen.dart';
import '../../features/modalverben/screens/modalverben_list_screen.dart';
import '../../features/modalverben/screens/modalverben_detail_screen.dart';
import '../../features/modalverben/models/modal_verb.dart';
import '../../features/grammatik/screens/grammar_topic_screen.dart';
import '../../features/vokabular/screens/wort_seite_screen.dart';
import '../../features/redemittel/models/redemittel_item.dart';
import '../../features/redemittel/controllers/redemittel_controller.dart';
import '../constants/app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path   : AppRoutes.home,
      builder: (ctx, _) => const HomeScreen(),
    ),

    // ── Wortschatz (فاز ۱ — LIVE) ────────────────────────────
    GoRoute(
      path   : AppRoutes.wortschatz,
      builder: (ctx, _) => const WortschatzHomeScreen(),
      routes : [
        GoRoute(
          path   : 'list',
          builder: (ctx, state) => WortschatzListScreen(
            initialQuery: state.uri.queryParameters['suche'] ?? '',
          ),
        ),
        GoRoute(
          path   : 'add',
          builder: (ctx, _) => const AddWordScreen(),
        ),
        GoRoute(
          path   : 'level',
          builder: (ctx, state) {
            final level = state.uri.queryParameters['level'] ?? 'a1';
            return LevelWordsScreen(level: level);
          },
        ),
        GoRoute(
          path   : 'type',
          builder: (ctx, state) {
            final type = state.uri.queryParameters['type'] ?? 'nomen';
            return TypeWordsScreen(type: type);
          },
        ),
        GoRoute(
          path   : 'books',
          builder: (ctx, _) => const BookListScreen(),
          routes : [
            GoRoute(
              path   : ':bookId',
              builder: (ctx, state) {
                final id   = int.parse(state.pathParameters['bookId']!);
                final name = state.uri.queryParameters['name'];
                return BookWordsScreen(bookId: id, bookName: name);
              },
            ),
          ],
        ),
        GoRoute(
          path   : 'word/:wordId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['wordId']!);
            return WordDetailScreen(wordId: id);
          },
        ),
        GoRoute(
          path   : 'categories',
          builder: (ctx, _) => const CategoryListScreen(),
          routes : [
            GoRoute(
              path   : ':categoryId',
              builder: (ctx, state) {
                final id   = int.parse(state.pathParameters['categoryId']!);
                final name = state.extra as String?;
                return CategoryDetailScreen(categoryId: id, categoryName: name);
              },
            ),
          ],
        ),
      ],
    ),

    // ── Leitner (فاز ۲ — LIVE) ───────────────────────────────
    GoRoute(
      path   : AppRoutes.leitner,
      builder: (ctx, _) => const LeitnerHomeScreen(),
      routes : [
        GoRoute(
          path   : 'review',
          builder: (ctx, _) => const LeitnerReviewScreen(),
        ),
        GoRoute(
          path   : 'stats',
          builder: (ctx, _) => const LeitnerStatsScreen(),
        ),
      ],
    ),

    // ── Grammatik (فاز ۴ — LIVE) ─────────────────────────────
    GoRoute(
      path   : AppRoutes.grammatik,
      builder: (ctx, _) => const GrammatikHomeScreen(),
      routes : [
        GoRoute(
          path   : 'lesson/:lessonId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['lessonId']!);
            return LessonDetailScreen(lessonId: id);
          },
          routes : [
            GoRoute(
              path   : 'exercise',
              builder: (ctx, state) {
                final id = int.parse(state.pathParameters['lessonId']!);
                return GrammarExerciseScreen(lessonId: id);
              },
            ),
            GoRoute(
              path   : 'quiz',
              builder: (ctx, state) {
                final id = int.parse(state.pathParameters['lessonId']!);
                return GrammarQuizScreen(lessonId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path   : 'katalog/:view/:key',
          builder: (ctx, state) => GrammatikKatalogScreen(
            view : state.pathParameters['view']!,
            keyId: state.pathParameters['key']!,
          ),
        ),
        GoRoute(
          path   : 'thema/:topicId',
          builder: (ctx, state) => GrammarTopicScreen(
              topicId: state.pathParameters['topicId']!),
        ),
        GoRoute(
          path   : 'lektion/:slug',
          builder: (ctx, state) => GrammatikLektionScreen(
              slug: state.pathParameters['slug']!),
          routes : [
            // G7a: Übungen der Lektion
            GoRoute(
              path   : 'uebung',
              builder: (ctx, state) => GrammatikUebungScreen(
                  slug: state.pathParameters['slug']!),
            ),
          ],
        ),
        // G7b: vor ':level' registrieren
        GoRoute(
          path   : 'quiz-niveau/:level',
          builder: (ctx, state) => GrammatikNiveauTestScreen(
              level: state.pathParameters['level']!),
        ),
        GoRoute(
          path   : ':level',
          builder: (ctx, state) {
            final level = state.pathParameters['level']!;
            return LevelLessonsScreen(level: level);
          },
        ),
      ],
    ),

    // ── Lesen (فاز ۵ — LIVE) ─────────────────────────────────
    GoRoute(
      path   : AppRoutes.lesen,
      builder: (ctx, _) => const LesenHomeScreen(),
      routes : [
        GoRoute(
          path   : 'news',
          builder: (ctx, _) => const NewsScreen(),
        ),
        GoRoute(
          path   : 'text/:textId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['textId']!);
            return TextReaderScreen(textId: id);
          },
        ),
        GoRoute(
          path   : ':level',
          builder: (ctx, state) {
            final level = state.pathParameters['level']!;
            return LevelTextsScreen(level: level);
          },
        ),
      ],
    ),

    // ── Hören (فاز ۶ — LIVE) ─────────────────────────────────
    GoRoute(
      path   : AppRoutes.hoeren,
      builder: (ctx, _) => const HoerenHomeScreen(),
      routes : [
        GoRoute(
          path   : 'karaoke/:audioId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['audioId']!);
            return KaraokeScreen(audioId: id);
          },
        ),
        GoRoute(
          path   : 'shadowing/:audioId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['audioId']!);
            return ShadowingScreen(audioId: id);
          },
        ),
        GoRoute(
          path   : 'quiz/:audioId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['audioId']!);
            return HoerenQuizScreen(audioId: id);
          },
        ),
        GoRoute(
          path   : ':level',
          builder: (ctx, state) {
            final level = state.pathParameters['level']!;
            return LevelAudioListScreen(level: level);
          },
        ),
      ],
    ),

    // ── Sprechen (فاز ۱۳ — stub LIVE) ───────────────────────
    GoRoute(
      path   : AppRoutes.sprechen,
      builder: (ctx, _) => const SprechenHomeScreen(),
    ),

    // ── Schreiben (فاز ۱۳ — stub LIVE) ──────────────────────
    GoRoute(
      path   : AppRoutes.schreiben,
      builder: (ctx, _) => const SchreibenHomeScreen(),
    ),

    // ── Search (فاز ۱۱ — LIVE) ───────────────────────────────
    GoRoute(
      path   : AppRoutes.search,
      builder: (ctx, state) {
        final q = state.uri.queryParameters['q'] ?? '';
        return SearchResultsScreen(initialQuery: q);
      },
    ),

    // ── Import (فاز ۱۲ — LIVE) ───────────────────────────────
    GoRoute(
      path   : AppRoutes.contentImport,
      builder: (ctx, _) => const ImportScreen(),
    ),

    // ── Auswendiglernen (فاز ۷ — LIVE) ──────────────────────
    GoRoute(
      path   : AppRoutes.auswendiglernen,
      builder: (ctx, _) => const AuswendiglernHomeScreen(),
      routes : [
        GoRoute(
          path   : ':categoryId',
          builder: (ctx, state) {
            final idx = int.parse(state.pathParameters['categoryId']!);
            return CategoryItemsScreen(categoryIndex: idx);
          },
          routes: [
            GoRoute(
              path   : 'memorize',
              builder: (ctx, state) {
                final idx = int.parse(state.pathParameters['categoryId']!);
                return MemorizeCardScreen(categoryIndex: idx);
              },
            ),
            GoRoute(
              path   : 'cloze',
              builder: (ctx, state) {
                final idx = int.parse(state.pathParameters['categoryId']!);
                return ClozePracticeScreen(categoryIndex: idx);
              },
            ),
          ],
        ),
      ],
    ),

    // ── Prüfungen (فاز ۸ — LIVE) ─────────────────────────────
    GoRoute(
      path   : AppRoutes.pruefungen,
      builder: (ctx, _) => const PruefungenHomeScreen(),
      routes : [
        GoRoute(
          path   : ':type',
          builder: (ctx, state) {
            final org = state.pathParameters['type']!;
            return ExamTypeScreen(orgKey: org);
          },
          routes: [
            GoRoute(
              path   : ':level/simulation',
              builder: (ctx, state) {
                final org   = state.pathParameters['type']!;
                final level = state.pathParameters['level']!;
                return ExamSimulationScreen(orgKey: org, level: level);
              },
            ),
          ],
        ),
      ],
    ),

    // ── Selbstlernen (فاز ۹ — LIVE) ─────────────────────────
    GoRoute(
      path   : AppRoutes.selbstlernen,
      builder: (ctx, _) => const SelbstlernenHomeScreen(),
      routes : [
        GoRoute(
          path   : 'pomodoro',
          builder: (ctx, _) => const PomodoroScreen(),
        ),
        GoRoute(
          path   : 'leitfaden',
          builder: (ctx, _) => const LeitfadenScreen(),
        ),
        GoRoute(
          path   : 'vorlagen',
          builder: (ctx, _) => const VorlagenScreen(),
        ),
      ],
    ),

    // ── Fragen (فاز ۱۰ — LIVE) ──────────────────────────────
    GoRoute(
      path   : AppRoutes.fragen,
      builder: (ctx, _) => const FragenScreen(),
    ),

    // ── Sozialmedien (فاز ۱۰ — LIVE) ────────────────────────
    GoRoute(
      path   : AppRoutes.sozialmedien,
      builder: (ctx, _) => const SozialmedienScreen(),
    ),

    // ── Konnektoren ───────────────────────────────────────────
    GoRoute(
      path   : AppRoutes.konnektoren,
      builder: (ctx, _) => const KonnektorenHomeScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const KonnektorenGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final entries = state.extra as List<KonnektorRich>?;
            if (entries != null && entries.isNotEmpty) {
              return KonnektorenQuizScreen(richEntries: entries);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(konnektorenRichProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (map) => KonnektorenQuizScreen(richEntries: map.values.toList()),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':konnektorId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['konnektorId']!);
            return KonnektorDetailScreen(konnektorId: id);
          },
        ),
      ],
    ),

    // ── More (فاز ۱۰ — LIVE) ─────────────────────────────────
    // ── Dativ-Verben ──────────────────────────────────────────
    GoRoute(
      path   : AppRoutes.dativVerben,
      builder: (ctx, _) => const DativVerbenListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const DativGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final verbs = state.extra as List<DativVerb>?;
            if (verbs != null && verbs.isNotEmpty) {
              return DativVerbenQuizScreen(verbs: verbs);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(dativVerbenProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => DativVerbenQuizScreen(verbs: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['verbId']!);
            return DativVerbenDetailScreen(verbId: id);
          },
        ),
      ],
    ),

    // ── NVV (Nomen-Verb-Verbindungen) ────────────────────────
    GoRoute(
      path   : AppRoutes.nvv,
      builder: (ctx, _) => const NvvHomeScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const NvvGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final phrases = state.extra as List<NvvPhrase>?;
            if (phrases != null && phrases.isNotEmpty) {
              return NvvQuizScreen(phrases: phrases);
            }
            // navigate from Prüfungen or Grammatik — load all phrases
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(nvvPhrasesProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => NvvQuizScreen(phrases: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':phraseId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['phraseId']!);
            return NvvDetailScreen(phraseId: id);
          },
        ),
      ],
    ),

    // ── Präpositionen ─────────────────────────────────────────
    GoRoute(
      path   : AppRoutes.praepositionen,
      builder: (ctx, _) => const PraepositonenHomeScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const PraepositonenGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final clusters = state.extra as List<PraepCluster>?;
            if (clusters != null && clusters.isNotEmpty) {
              return PraepositonenQuizScreen(clusters: clusters);
            }
            // navigate from Prüfungen or Grammatik — load all clusters
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(praepClusterProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => PraepositonenQuizScreen(clusters: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':clusterId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['clusterId']!);
            return PraepClusterDetailScreen(clusterId: id);
          },
        ),
      ],
    ),

    // ── Reflexivverben ────────────────────────────────────────
    GoRoute(
      path   : AppRoutes.reflexiv,
      builder: (ctx, _) => const ReflexivListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const ReflexivGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final verbs = state.extra as List<ReflexivVerb>?;
            if (verbs != null && verbs.isNotEmpty) {
              return ReflexivQuizScreen(verbs: verbs);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(reflexivVerbenProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => ReflexivQuizScreen(verbs: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['verbId']!);
            return ReflexivDetailScreen(verbId: id);
          },
        ),
      ],
    ),

    // ── Trennbare / Untrennbare Verben ────────────────────────
    GoRoute(
      path   : AppRoutes.trennbar,
      builder: (ctx, _) => const TrennbarListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const TrennbarGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final verbs = state.extra as List<TrennbarVerb>?;
            if (verbs != null && verbs.isNotEmpty) {
              return TrennbarQuizScreen(verbs: verbs);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(trennbarVerbenProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => TrennbarQuizScreen(verbs: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['verbId']!);
            return TrennbarDetailScreen(verbId: id);
          },
        ),
      ],
    ),

    // ── Verben mit Präpositionen ──────────────────────────────
    GoRoute(
      path   : AppRoutes.verbPraep,
      builder: (ctx, _) => const VerbPraepListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const VerbPraepGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final verbs = state.extra as List<VerbPraep>?;
            if (verbs != null && verbs.isNotEmpty) {
              return VerbPraepQuizScreen(verbs: verbs);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(verbPraepProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => VerbPraepQuizScreen(verbs: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['verbId']!);
            return VerbPraepDetailScreen(verbId: id);
          },
        ),
      ],
    ),

    // ── Redemittel 1010 ───────────────────────────────────────
    GoRoute(
      path   : AppRoutes.redemittel1010,
      builder: (ctx, _) => const Redemittel1010ListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const Redemittel1010GrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final items = state.extra as List<RedemittelItem>?;
            if (items != null && items.isNotEmpty) {
              return Redemittel1010QuizScreen(phrases: items);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(redemittel1010Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010QuizScreen(phrases: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':phraseId',
          builder: (ctx, state) {
            final id     = int.parse(state.pathParameters['phraseId']!);
            final phrase = state.extra as RedemittelItem?;
            return Redemittel1010DetailScreen(phraseId: id, phrase: phrase);
          },
        ),
      ],
    ),

    // ── Redemittel — Goethe B2 (Prüfungsdeck) ─────────────────
    GoRoute(
      path   : AppRoutes.redemittelGoetheB2,
      builder: (ctx, _) => RedemittelExamListScreen(
        title   : 'Goethe B2 Redemittel',
        provider: redemittelGoetheB2Provider,
        basePath: AppRoutes.redemittelGoetheB2,
      ),
      routes : [
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final items = state.extra as List<RedemittelItem>?;
            if (items != null && items.isNotEmpty) {
              return Redemittel1010QuizScreen(phrases: items);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelGoetheB2Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010QuizScreen(phrases: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':phraseId',
          builder: (ctx, state) {
            final id     = int.parse(state.pathParameters['phraseId']!);
            final phrase = state.extra as RedemittelItem?;
            if (phrase != null) {
              return Redemittel1010DetailScreen(phraseId: id, phrase: phrase);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelGoetheB2Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010DetailScreen(
                  phraseId: id,
                  phrase  : list.firstWhere((p) => p.id == id),
                ),
              ),
            );
          },
        ),
      ],
    ),

    // ── Redemittel — ÖSD B2 (Prüfungsdeck) ────────────────────
    GoRoute(
      path   : AppRoutes.redemittelOesdB2,
      builder: (ctx, _) => RedemittelExamListScreen(
        title   : 'ÖSD B2 Redemittel',
        provider: redemittelOesdB2Provider,
        basePath: AppRoutes.redemittelOesdB2,
      ),
      routes : [
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final items = state.extra as List<RedemittelItem>?;
            if (items != null && items.isNotEmpty) {
              return Redemittel1010QuizScreen(phrases: items);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelOesdB2Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010QuizScreen(phrases: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':phraseId',
          builder: (ctx, state) {
            final id     = int.parse(state.pathParameters['phraseId']!);
            final phrase = state.extra as RedemittelItem?;
            if (phrase != null) {
              return Redemittel1010DetailScreen(phraseId: id, phrase: phrase);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelOesdB2Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010DetailScreen(
                  phraseId: id,
                  phrase  : list.firstWhere((p) => p.id == id),
                ),
              ),
            );
          },
        ),
      ],
    ),

    // ── Redemittel — ÖSD C1 (Prüfungsdeck) ────────────────────
    GoRoute(
      path   : AppRoutes.redemittelOesdC1,
      builder: (ctx, _) => RedemittelExamListScreen(
        title   : 'ÖSD C1 Redemittel',
        provider: redemittelOesdC1Provider,
        basePath: AppRoutes.redemittelOesdC1,
      ),
      routes : [
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final items = state.extra as List<RedemittelItem>?;
            if (items != null && items.isNotEmpty) {
              return Redemittel1010QuizScreen(phrases: items);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelOesdC1Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010QuizScreen(phrases: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':phraseId',
          builder: (ctx, state) {
            final id     = int.parse(state.pathParameters['phraseId']!);
            final phrase = state.extra as RedemittelItem?;
            if (phrase != null) {
              return Redemittel1010DetailScreen(phraseId: id, phrase: phrase);
            }
            return Consumer(
              builder: (ctx, ref, _) =>
                  ref.watch(redemittelOesdC1Provider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => Redemittel1010DetailScreen(
                  phraseId: id,
                  phrase  : list.firstWhere((p) => p.id == id),
                ),
              ),
            );
          },
        ),
      ],
    ),

    // ── Modalverben ───────────────────────────────────────────
    GoRoute(
      path   : AppRoutes.modalverben,
      builder: (ctx, _) => const ModalverbenListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) =>
              const GrammarTopicScreen(topicId: 'modalverben'),
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id   = state.pathParameters['verbId']!;
            final verb = state.extra as ModalVerb?;
            return ModalverbenDetailScreen(verbId: id, verb: verb);
          },
        ),
      ],
    ),

    // ── Unregelmäßige Verben ──────────────────────────────────
    GoRoute(
      path   : AppRoutes.unregelVerben,
      builder: (ctx, _) => const UnregelmListScreen(),
      routes : [
        GoRoute(
          path   : 'grammar',
          builder: (ctx, _) => const UnregelmGrammarScreen(),
        ),
        GoRoute(
          path   : 'quiz',
          builder: (ctx, state) {
            final verbs = state.extra as List<UnregelmVerb>?;
            if (verbs != null && verbs.isNotEmpty) {
              return UnregelmQuizScreen(verbs: verbs);
            }
            return Consumer(
              builder: (ctx, ref, _) => ref.watch(unregelVerbenProvider).when(
                loading: () => const _LoadingScaffold(),
                error  : (e, _) => _ErrorScaffold(e),
                data   : (list) => UnregelmQuizScreen(verbs: list),
              ),
            );
          },
        ),
        GoRoute(
          path   : ':verbId',
          builder: (ctx, state) {
            final id = int.parse(state.pathParameters['verbId']!);
            return UnregelmDetailScreen(verbId: id);
          },
        ),
      ],
    ),

    // ── Wort-Seite der Vokabular-Karten (فاز V) — Liste: «Alle Wörter» ──
    GoRoute(
      path   : AppRoutes.vokabularWortDetail,
      builder: (ctx, state) =>
          WortSeiteScreen(wortId: state.pathParameters['id']!),
    ),

    GoRoute(
      path   : AppRoutes.more,
      builder: (ctx, _) => const MoreHomeScreen(),
      routes : [
        GoRoute(
          path   : 'settings',
          builder: (ctx, _) => const SettingsScreen(),
        ),
        GoRoute(
          path   : 'profil',
          builder: (ctx, _) => const ProfilScreen(),
        ),
        GoRoute(
          path   : 'privacy',
          builder: (ctx, _) => const PrivacyPolicyScreen(),
        ),
      ],
    ),
  ],
);

// ─── router-internal helpers ──────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold(this.error);
  final Object error;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('$error')));
}
