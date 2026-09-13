// FILE: lib/core/services/tts_service.dart
// DEPS: flutter_tts
// PURPOSE: Singleton TTS service — one FlutterTts instance shared across all widgets
//          Tracks currently playing text so buttons can show correct state
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class TtsPlayState {
  const TtsPlayState({this.playing = false, this.currentText, this.rate = 0.85});
  final bool    playing;
  final String? currentText;
  final double  rate;

  bool isPlayingText(String text) => playing && currentText == text;

  TtsPlayState copyWith({
    bool?    playing,
    String?  currentText,
    double?  rate,
    bool     clearText = false,
  }) =>
      TtsPlayState(
        playing    : playing     ?? this.playing,
        currentText: clearText ? null : (currentText ?? this.currentText),
        rate       : rate        ?? this.rate,
      );
}

// ── Service notifier ──────────────────────────────────────────────────────────

class TtsService extends Notifier<TtsPlayState> {
  late final FlutterTts _tts;

  @override
  TtsPlayState build() {
    _tts = FlutterTts();
    _init();
    ref.onDispose(() => _tts.stop());
    return const TtsPlayState();
  }

  Future<void> _init() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(state.rate);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(
        () => state = state.copyWith(playing: false, clearText: true));
    _tts.setCancelHandler(
        () => state = state.copyWith(playing: false, clearText: true));
    _tts.setErrorHandler(
        (_) => state = state.copyWith(playing: false, clearText: true));
  }

  Future<void> speak(String text) async {
    if (state.playing) await _tts.stop();
    state = TtsPlayState(playing: true, currentText: text, rate: state.rate);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = state.copyWith(playing: false, clearText: true);
  }

  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate);
    state = state.copyWith(rate: rate);
  }

  void toggle(String text) {
    if (state.isPlayingText(text)) {
      stop();
    } else {
      speak(text);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final ttsServiceProvider =
    NotifierProvider<TtsService, TtsPlayState>(TtsService.new);
