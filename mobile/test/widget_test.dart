import 'package:flutter_test/flutter_test.dart';
import 'package:umkmate/main.dart';

void main() {
  testWidgets('UMKMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UMKMateApp());

    // Verify that UMKMate title appears on splash screen
    expect(find.text('UMKMate'), findsOneWidget);

    // Advance time past the splash timer (1500ms)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  });
}


