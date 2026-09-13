// ═══════════════════════════════════════════════════════════════════════════════
// FILE: test/helpers/mock_data_factory.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Central test-data factory — every test builds its fixtures here
//          instead of hand-rolling model instances. Model changes → fix one file.
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   abstract final class MockDataFactory
//
//   MODELS (one maker per model, all-args optional with sane defaults):
//     static RedemittelItem redemittelItem({int id = 1, String? phraseDe, ...})
//     static Konnektor konnektor({...})
//     static DativVerb dativVerb({...})
//     static ReflexivVerb reflexivVerb({...})
//     static TrennbarVerb trennbarVerb({...})
//     static VerbPraep verbPraep({...})
//     static UnregelmVerb unregelmVerb({...})
//
//   LISTS:
//     static List<RedemittelItem> redemittelItems(int count)
//         — distinct ids/phrases, enough distractors for quiz logic tests
//
//   DB:
//     static Future<AppDatabase> inMemoryDb()
//         — drift NativeDatabase.memory() for DAO tests
//
//   RIVERPOD:
//     static ProviderContainer container({List<Override> overrides})
//         — pre-wired with in-memory db + fake services
//
// MIGRATION PLAN (Phase B12):
//   1. Implement factory for RedemittelItem + inMemoryDb first
//   2. Add quiz-logic unit tests (question building, distractor fallback)
//   3. Add DAO tests (Leitner box moves, memorize categories)
