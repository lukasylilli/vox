// FILE: test/persistent_storage_test.dart
// PHASE: فاز S, Schritt S.1
// Prüft die Weiche, nicht den Browser: auf der Dart-VM muss die io-Fassung
// greifen und ruhig `false` liefern. Fiele hier versehentlich die web-Fassung
// hinein (ungeschütztes package:web), bräche der Test — genau dafür ist er da.
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/core/utils/persistent_storage.dart';

void main() {
  test('requestPersistentStorage liefert auf der VM false statt zu werfen',
      () async {
    expect(await requestPersistentStorage(), isFalse);
  });
}
