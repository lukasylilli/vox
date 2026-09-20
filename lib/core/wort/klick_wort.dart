// FILE: lib/core/wort/klick_wort.dart
// DEPS: wort_form.dart (reines Dart, kein Flutter)
// PURPOSE: Zerlegt einen deutschen Text in Wörter und «Rest» (Leerraum,
//          Satzzeichen, Ziffern) — die Grundlage von KlickWortText (L.5f).
//
// Jedes Zeichen des Textes landet in genau EINEM Token, in Originalreihenfolge:
// `tokens.map((t) => t.text).join() == text`. Nichts geht verloren, nichts wird
// doppelt — der Text sieht nach dem Zerlegen exakt so aus wie vorher.
import 'wort_form.dart';

/// Ein Stück Text: entweder ein Wort (antippbar) oder Rest (nicht antippbar).
class KlickToken {
  const KlickToken(this.text, {required this.istWort});

  final String text;
  final bool istWort;

  @override
  String toString() => istWort ? 'Wort($text)' : 'Rest($text)';
}

final RegExp _tokenMuster =
    RegExp('[$wortBuchstaben]+|[^$wortBuchstaben]+');
final RegExp _beginntMitBuchstabe = RegExp('^[$wortBuchstaben]');

/// Text → Wörter und Rest. Ein Bindestrich trennt Wörter («E-Mail» → E, -, Mail):
/// das ist vorhersagbar und hat dieselbe Regel wie der bisherige Leser.
List<KlickToken> zerlegeText(String text) => [
      for (final m in _tokenMuster.allMatches(text))
        KlickToken(m.group(0)!,
            istWort: _beginntMitBuchstabe.hasMatch(m.group(0)!)),
    ];
