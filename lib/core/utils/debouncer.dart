// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/utils/debouncer.dart
// STATUS: [ ] stub — code pending
// PURPOSE: Debounce helper — delays rapid-fire callbacks (search-as-you-type)
//          so filtering 900+ items doesn't run on every keystroke.
// ═══════════════════════════════════════════════════════════════════════════════
//
// PLANNED CONTENTS:
//   class Debouncer {
//     Debouncer({this.delay = const Duration(milliseconds: 250)});
//     void run(VoidCallback action)   — resets timer on each call
//     void dispose()                  — cancel pending timer
//   }
//
// USAGE (list screens):
//   final _debouncer = Debouncer();
//   VoxSearchField(onChanged: (v) => _debouncer.run(() => notifier.setQuery(v)))
//
// WIRE INTO: redemittel_1010_list (908 items!), wortschatz_list, nvv_home
