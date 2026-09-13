// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/backup_service.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Export/import user data (Leitner progress, own words, categories,
//          habits) as a single JSON file — device change without data loss.
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class BackupService {
//     BackupService(this._db);
//     Future<File> exportToFile()          — all user tables → vox_backup.json
//     Future<BackupSummary> importFromFile(File f)
//         — validates schema version, merges (no blind overwrite)
//     Future<String> exportAsText()        — for share sheet
//   }
//
//   class BackupSummary { int words; int cards; int categories; int habits; }
//
//   final backupServiceProvider = Provider<BackupService>(...)
//
// TABLES COVERED: Words (userAdded only), LeitnerCards, UserCategories,
//                 CategoryWords, MemorizeItems, Habits, HabitSessions
//
// WIRE INTO: settings_screen (export/import section), import_screen
// NOTE: share/file-picker deps (share_plus, file_picker) erst bei Implementierung.
