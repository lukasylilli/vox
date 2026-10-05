// FILE: lib/features/selbstlernen/services/pomodoro_geraet_web.dart
// PURPOSE: Browser-Fassung — siehe pomodoro_geraet.dart.
//
// • Wake Lock: `navigator.wakeLock.request('screen')`. Der Browser gibt die
//   Sperre selbst frei, sobald die Seite verborgen wird (Tabwechsel, Sperren
//   von Hand) — deshalb fragt der Notifier beim Zurückkehren erneut an.
// • Ton: ein Web-Audio-Dreiklang aus Sinustönen — keine Audiodatei, kein
//   Netz, kein neues Paket. Der AudioContext entsteht beim Tippen auf Start.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'pomodoro_geraet_basis.dart';

class _WebWach implements BildschirmWach {
  web.WakeLockSentinel? _sentinel;
  bool _gewollt = false;
  bool _anfrageLaeuft = false;

  @override
  Future<bool> halten() async {
    _gewollt = true;
    final s = _sentinel;
    if (s != null && !s.released) return true;
    if (_anfrageLaeuft) return false;
    _anfrageLaeuft = true;
    try {
      // Ältere Browser kennen die API nicht ⇒ still verzichten.
      if (!web.window.navigator.has('wakeLock')) return false;
      final neu = await web.window.navigator.wakeLock.request('screen').toDart;
      if (!_gewollt) {
        // Während der Anfrage wurde schon wieder losgelassen.
        unawaited(neu.release().toDart.then<void>((_) {}, onError: (_) {}));
        return false;
      }
      _sentinel = neu;
      return true;
    } catch (_) {
      _sentinel = null;
      return false;
    } finally {
      _anfrageLaeuft = false;
    }
  }

  @override
  Future<void> loslassen() async {
    _gewollt = false;
    final s = _sentinel;
    _sentinel = null;
    if (s == null) return;
    try {
      if (!s.released) await s.release().toDart;
    } catch (_) {
      // schon freigegeben — nichts zu tun
    }
  }
}

class _WebKlang implements PomodoroKlang {
  web.AudioContext? _kontext;

  web.AudioContext? _holen() {
    try {
      return _kontext ??= web.AudioContext();
    } catch (_) {
      return null;
    }
  }

  @override
  void vorbereiten() {
    final c = _holen();
    if (c == null) return;
    try {
      if (c.state == 'suspended') {
        unawaited(c.resume().toDart.then<void>((_) {}, onError: (_) {}));
      }
    } catch (_) {
      // kein Ton — der Timer selbst ist davon unabhängig
    }
  }

  @override
  Future<void> spielen() async {
    final c = _holen();
    if (c == null) return;
    try {
      if (c.state == 'suspended') await c.resume().toDart;
      const noten = <double>[880.0, 1108.73, 1318.51]; // A5 · C#6 · E6 (A-Dur)
      final start = c.currentTime + 0.03;
      for (var i = 0; i < noten.length; i++) {
        final t = start + i * 0.22;
        final osc = c.createOscillator();
        final gain = c.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(noten[i], t);
        gain.gain.setValueAtTime(0.0001, t);
        gain.gain.linearRampToValueAtTime(0.25, t + 0.03);
        gain.gain.linearRampToValueAtTime(0.0001, t + 0.2);
        osc.connect(gain);
        gain.connect(c.destination);
        osc.start(t);
        osc.stop(t + 0.22);
      }
    } catch (_) {
      // Browser hat den Ton nicht freigegeben — still bleiben
    }
  }
}

BildschirmWach neuerBildschirmWach() => _WebWach();
PomodoroKlang neuerPomodoroKlang() => _WebKlang();
