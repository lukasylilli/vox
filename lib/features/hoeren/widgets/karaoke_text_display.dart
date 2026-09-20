// FILE: lib/features/hoeren/widgets/karaoke_text_display.dart
// DEPS: hoeren_controller.dart, audio_service.dart
// PURPOSE: Scrollable transcript — highlights the word at current audio position
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/wort_popup.dart';
import '../controllers/hoeren_controller.dart';

class KaraokeTextDisplay extends ConsumerWidget {
  const KaraokeTextDisplay({
    super.key,
    required this.words,
  });

  final List<TranscriptWord> words;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posMs  = ref.watch(audioServiceProvider).position.inMilliseconds;
    final scheme = Theme.of(context).colorScheme;

    int activeIndex = -1;
    for (var i = 0; i < words.length; i++) {
      if (posMs >= words[i].startMs && posMs <= words[i].endMs) {
        activeIndex = i;
        break;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing   : 4,
        runSpacing: 8,
        children  : List.generate(words.length, (i) {
          final isActive = i == activeIndex;
          // L.5f: Wort antippen → Popup → Wort-Seite (wie überall in der App)
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showWortPopup(context, words[i].word),
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding : const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color       : isActive ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              words[i].word,
              style: TextStyle(
                fontSize  : 18,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color     : isActive
                    ? scheme.onPrimary
                    : scheme.onSurface,
              ),
            ),
          ));
        }),
      ),
    );
  }
}
