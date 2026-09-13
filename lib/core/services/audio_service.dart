// FILE: lib/core/services/audio_service.dart
// DEPS: just_audio
// PURPOSE: Singleton just_audio wrapper — load/play/pause/seek/speed + position stream
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayState {
  const AudioPlayState({
    this.playing    = false,
    this.position   = Duration.zero,
    this.duration   = Duration.zero,
    this.speed      = 1.0,
    this.currentPath,
    this.completed  = false,
  });

  final bool     playing;
  final Duration position;
  final Duration duration;
  final double   speed;
  final String?  currentPath;
  final bool     completed;

  bool get isLoaded => currentPath != null;

  double get progress => duration.inMilliseconds == 0
      ? 0
      : position.inMilliseconds / duration.inMilliseconds;

  AudioPlayState copyWith({
    bool?     playing,
    Duration? position,
    Duration? duration,
    double?   speed,
    String?   currentPath,
    bool?     completed,
    bool      clearPath = false,
  }) =>
      AudioPlayState(
        playing    : playing     ?? this.playing,
        position   : position    ?? this.position,
        duration   : duration    ?? this.duration,
        speed      : speed       ?? this.speed,
        currentPath: clearPath   ? null : (currentPath ?? this.currentPath),
        completed  : completed   ?? this.completed,
      );
}

class AudioService extends Notifier<AudioPlayState> {
  late final AudioPlayer _player;
  StreamSubscription<Duration>?       _posSub;
  StreamSubscription<Duration?>?      _durSub;
  StreamSubscription<PlayerState>?    _stateSub;

  @override
  AudioPlayState build() {
    _player = AudioPlayer();

    _posSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos, completed: false);
    });

    _durSub = _player.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    _stateSub = _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) {
        state = state.copyWith(
          playing  : false,
          completed: true,
          position : state.duration,
        );
      } else {
        state = state.copyWith(playing: s.playing, completed: false);
      }
    });

    ref.onDispose(() {
      _posSub?.cancel();
      _durSub?.cancel();
      _stateSub?.cancel();
      _player.dispose();
    });

    return const AudioPlayState();
  }

  // Load audio and reset position. Web hat kein Dateisystem:
  // 'assets/...' → gebündeltes Asset, alles andere → URL.
  Future<void> load(String path) async {
    await _player.stop();
    state = AudioPlayState(speed: state.speed, currentPath: path);
    try {
      if (path.startsWith('assets/')) {
        await _player.setAsset(path);
      } else {
        await _player.setUrl(path);
      }
    } catch (_) {
      // File may not exist yet — show graceful empty state
    }
  }

  Future<void> play()  => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> toggle() {
    return state.playing ? pause() : play();
  }

  Future<void> seek(Duration pos) => _player.seek(pos);

  Future<void> seekBy(Duration delta) {
    var target = state.position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > state.duration) target = state.duration;
    return _player.seek(target);
  }

  Future<void> stop() async {
    await _player.stop();
    state = AudioPlayState(speed: state.speed);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }
}

final audioServiceProvider =
    NotifierProvider<AudioService, AudioPlayState>(AudioService.new);
