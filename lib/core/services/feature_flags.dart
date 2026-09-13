// FILE: lib/core/services/feature_flags.dart
// STATUS: [x] LIVE (B5 — 2026-07-04)
// PURPOSE: Central feature flags — which decks/features are live or coming
//          soon. Turning a deck live = one line change HERE, nowhere else.
//          Deck lists and content_registry read from this file.

enum FeatureState { live, comingSoon, hidden }

abstract final class FeatureFlags {
  static const Map<String, FeatureState> _flags = {
    // ── Auswendiglernen learning decks ────────────────────────────────────
    'deck.konnektoren'        : FeatureState.live,
    'deck.dativ_verben'       : FeatureState.live,
    'deck.nvv'                : FeatureState.live,
    'deck.praepositionen'     : FeatureState.live,
    'deck.redewendungen'      : FeatureState.live,
    'deck.relativsatz'        : FeatureState.comingSoon,
    'deck.unregelm_verben'    : FeatureState.live,
    'deck.trennbar_verben'    : FeatureState.live,
    'deck.reflexiv_verben'    : FeatureState.live,
    'deck.verb_praep'         : FeatureState.live,
    'deck.modalverben'        : FeatureState.live,
    'deck.da_praepositionen'  : FeatureState.comingSoon,
    'deck.adjektive'          : FeatureState.comingSoon,
    'deck.adjektivdeklination': FeatureState.comingSoon,
    'deck.tempusformen'       : FeatureState.comingSoon,

    // ── Prüfungen decks ───────────────────────────────────────────────────
    'deck.goethe_b2'          : FeatureState.live,
    'deck.oesd_b2'            : FeatureState.live,
    'deck.oesd_c1'            : FeatureState.comingSoon,
    'deck.redemittel_1010'    : FeatureState.live,
    'deck.zusammenfassung'    : FeatureState.comingSoon,
    'deck.a2_zusammenfassung' : FeatureState.comingSoon,

    // ── App features ──────────────────────────────────────────────────────
    'feature.sprechen'        : FeatureState.comingSoon,
    'feature.schreiben'       : FeatureState.comingSoon,
  };

  /// Unknown keys are treated as live (fail open) so a missing entry never
  /// accidentally hides shipped content.
  static FeatureState of(String key) => _flags[key] ?? FeatureState.live;

  static bool isLive(String key) => of(key) == FeatureState.live;
  static bool isComingSoon(String key) => of(key) == FeatureState.comingSoon;
}
