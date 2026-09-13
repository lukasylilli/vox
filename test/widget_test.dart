import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vox/app.dart';

void main() {
  testWidgets('VOX app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VoxApp()));
    await tester.pumpAndSettle();
    expect(find.text('VOX'), findsWidgets);
  });
}
