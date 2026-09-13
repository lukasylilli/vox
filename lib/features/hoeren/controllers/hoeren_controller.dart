// FILE: lib/features/hoeren/controllers/hoeren_controller.dart
// DEPS: hoeren_dao.dart, audio_service.dart, app_database.dart
// PURPOSE: Providers für Hören — audio list, level counts, transcript parsing
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/hoeren_dao.dart';
import '../../wortschatz/controllers/word_controller.dart';

export '../../../core/services/audio_service.dart' show audioServiceProvider, AudioPlayState, AudioService;

// ── DAO ──────────────────────────────────────────────────────────────────────

final hoerenDaoProvider = Provider<HoerenDao>(
  (ref) => HoerenDao(ref.watch(databaseProvider)),
);

// ── Audio list providers ──────────────────────────────────────────────────────

final allAudioProvider = StreamProvider<List<AudioItem>>(
  (ref) => ref.watch(hoerenDaoProvider).watchAll(),
);

final audioByLevelProvider = StreamProvider.family<List<AudioItem>, String>(
  (ref, level) => ref.watch(hoerenDaoProvider).watchByLevel(level),
);

final audioByIdProvider = FutureProvider.family<AudioItem?, int>(
  (ref, id) => ref.watch(hoerenDaoProvider).getById(id),
);

final audioLevelCountsProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(hoerenDaoProvider).countByLevel(),
);

// ── Transcript ────────────────────────────────────────────────────────────────

class TranscriptWord {
  const TranscriptWord({
    required this.word,
    required this.startMs,
    required this.endMs,
  });

  final String word;
  final int    startMs;
  final int    endMs;

  factory TranscriptWord.fromJson(Map<String, dynamic> j) => TranscriptWord(
        word   : j['word'] as String,
        startMs: j['startMs'] as int,
        endMs  : j['endMs'] as int,
      );
}

final transcriptProvider = FutureProvider.family<List<TranscriptWord>, int>(
  (ref, audioId) async {
    final item = await ref.watch(audioByIdProvider(audioId).future);
    if (item == null || item.transcript == null) return [];
    final list = jsonDecode(item.transcript!) as List<dynamic>;
    return list
        .map((e) => TranscriptWord.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

// Active word index is computed in widgets directly from audioServiceProvider.position
// and the transcript list — no separate provider needed.

// ── Speed steps (shared with ReaderToolbar pattern) ───────────────────────────
const audioSpeedSteps = [0.5, 0.75, 1.0, 1.25, 1.5];
