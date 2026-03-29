import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/main.dart';

void main() {
  testWidgets('NullSignal smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NullSignalApp());

    // Verify system status text exists on NormalHomePage
    expect(find.text('System Status: Ready'), findsOneWidget);
    expect(find.text('ACTIVATE PANIC MODE'), findsOneWidget);

    // Tap the Panic Mode button
    await tester.tap(find.text('ACTIVATE PANIC MODE'));
    await tester.pumpAndSettle();

    // Verify we are now in SOS screen (PanicHomePage defaults to SOS index 1)
    expect(find.text('BROADCAST EMERGENCY'), findsOneWidget);
    expect(find.text('SEND SOS'), findsOneWidget);

    // Exit Panic Mode to stop SafetyMonitor timer
    await tester.tap(find.byIcon(Icons.exit_to_app));
    await tester.pumpAndSettle();
  });
}

