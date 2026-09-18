// FILE: lib/core/content/content_registry.dart
// PURPOSE: مرجع متمرکز همه منابع محتوای اپ — مسیر فایل، نوع، توضیح
//          هر بار محتوای جدید اضافه می‌شود این فایل به‌روز می‌شود — کد UI لمس نمی‌شود.
import '../../core/constants/app_routes.dart';
import '../services/feature_flags.dart';

enum ContentSource { json, database }

class ContentEntry {
  const ContentEntry({
    required this.id,
    required this.titleDe,
    required this.titleFa,
    required this.source,
    this.assetPath,
    this.route,
    required this.cefrLevels,
    required this.itemCount,
    this.flag = '',
  });

  final String        id;
  final String        titleDe;
  final String        titleFa;
  final ContentSource source;
  final String?       assetPath;
  final String?       route;
  final List<String>  cefrLevels;
  final int           itemCount;

  /// FeatureFlags key — '' = always live.
  final String        flag;

  /// Single source of truth: readiness comes from FeatureFlags, not from
  /// a locally stored bool.
  bool get isReady => FeatureFlags.isLive(flag);
}

// ─── Registry ─────────────────────────────────────────────────────────────────

const contentRegistry = [
  ContentEntry(
    id         : 'konnektoren',
    titleDe    : 'Satzkonnektoren',
    titleFa    : 'کانکتورهای جمله‌ای',
    source     : ContentSource.json,
    assetPath  : 'assets/data/konnektoren_data.json',
    route      : AppRoutes.konnektoren,
    cefrLevels : ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
    itemCount  : 186,
  ),
  ContentEntry(
    id         : 'dativ_verben',
    titleDe    : 'Dativ und Akkusativ Verben',
    titleFa    : 'افعال با Dativ و Akkusativ',
    source     : ContentSource.json,
    assetPath  : 'assets/data/dativ_akkusativ_data.json',
    route      : AppRoutes.dativVerben,
    cefrLevels : ['A1', 'A2', 'B1', 'B2'],
    itemCount  : 110,
  ),
  ContentEntry(
    id         : 'nvv',
    titleDe    : 'Nomen-Verb-Verbindungen',
    titleFa    : 'ترکیب‌های اسم-فعل (NVV)',
    source     : ContentSource.json,
    assetPath  : 'assets/data/nvv_data.json',
    route      : AppRoutes.nvv,
    cefrLevels : ['A1', 'A2', 'B1', 'B2', 'C1'],
    itemCount  : 346,
  ),
  ContentEntry(
    id         : 'praepositionen',
    titleDe    : 'Nomen · Verb · Adjektiv + Präpositionen',
    titleFa    : 'اسم، فعل و صفت با حروف اضافه',
    source     : ContentSource.json,
    assetPath  : 'assets/data/praepositionen_data.json',
    route      : AppRoutes.praepositionen,
    cefrLevels : ['A1', 'A2', 'B1', 'B2', 'C1'],
    itemCount  : 185,
  ),
  ContentEntry(
    id         : 'redemittel_goethe_b2',
    titleDe    : 'Goethe B2 Redemittel',
    titleFa    : 'عبارات Goethe B2',
    source     : ContentSource.json,
    assetPath  : 'assets/data/redemittel_goethe_b2.json',
    route      : AppRoutes.redemittelGoetheB2,
    cefrLevels : ['A2', 'B1', 'B2'],
    itemCount  : 61,
    flag       : 'deck.goethe_b2',
  ),
  ContentEntry(
    id         : 'redemittel_oesd_b2',
    titleDe    : 'ÖSD B2 Redemittel',
    titleFa    : 'عبارات ÖSD B2',
    source     : ContentSource.json,
    assetPath  : 'assets/data/redemittel_oesd_b2.json',
    route      : AppRoutes.redemittelOesdB2,
    cefrLevels : ['B2'],
    itemCount  : 121,
    flag       : 'deck.oesd_b2',
  ),
  ContentEntry(
    id         : 'redemittel_oesd_c1',
    titleDe    : 'ÖSD C1 Redemittel',
    titleFa    : 'عبارات ÖSD C1',
    source     : ContentSource.json,
    assetPath  : 'assets/data/redemittel_oesd_c1.json',
    route      : AppRoutes.redemittelOesdC1,
    cefrLevels : ['C1'],
    itemCount  : 112,
    flag       : 'deck.oesd_c1',
  ),
  ContentEntry(
    id         : 'redemittel_1010',
    titleDe    : '1010 Redemittel',
    titleFa    : '۱۰۱۰ عبارت کاربردی',
    source     : ContentSource.json,
    assetPath  : 'assets/data/redemittel_1010.json',
    route      : AppRoutes.redemittel1010,
    cefrLevels : ['B2', 'C1'],
    itemCount  : 908,
    flag       : 'deck.redemittel_1010',
  ),
  ContentEntry(
    id         : 'modalverben',
    titleDe    : 'Modalverben',
    titleFa    : 'افعال مُدال',
    source     : ContentSource.json,
    assetPath  : 'assets/data/modalverben_data.json',
    route      : AppRoutes.modalverben,
    cefrLevels : ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
    itemCount  : 7,
    flag       : 'deck.modalverben',
  ),
  ContentEntry(
    id         : 'wortschatz',
    titleDe    : 'Wortschatz',
    titleFa    : 'واژگان',
    source     : ContentSource.database,
    route      : AppRoutes.wortschatz,
    cefrLevels : ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
    itemCount  : 0,
  ),
];
