// FILE: test/helpers/wortschatz_overrides.dart
// PHASE: فاز F.4 (2026-10-14): «Alle Wörter» und die Filterseite lesen auch
//        Bücher (assets + drift) und eigene Kategorien (drift). In Widget-
//        Tests laufen echte drift-Streams und rootBundle in FakeAsync nie
//        sauber zu Ende — diese Overrides liefern feste, leere oder
//        vorgegebene Werte.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vox/core/database/app_database.dart';
import 'package:vox/features/categories/controllers/category_controller.dart';
import 'package:vox/features/wortschatz/controllers/word_controller.dart';
import 'package:vox/features/wortschatz/controllers/wortschatz_filter_controller.dart';
import 'package:vox/features/wortschatz/data/vox_buecher.dart';

List<Override> wortschatzGruppenOverrides({
  List<VoxBuch> buecher = const [],
}) =>
    [
      voxBuecherProvider.overrideWith((ref) async => buecher),
      allBooksProvider.overrideWith((ref) => Stream.value(<Book>[])),
      alleWortBuecherProvider
          .overrideWith((ref) => Stream.value(<WordBook>[])),
      allCategoriesProvider
          .overrideWith((ref) => Stream.value(<UserCategory>[])),
      alleKategorieWoerterProvider
          .overrideWith((ref) => Stream.value(<CategoryWord>[])),
    ];
