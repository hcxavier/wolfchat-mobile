import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/di/service_locator.dart';
import 'package:wolfchat/main.dart';

void main() {
  testWidgets('App renders home page', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: ServiceLocator.providers,
        child: const WolfChatApp(),
      ),
    );

    // Pump multiple times to allow async initialization to complete
    // pumpAndSettle can hang indefinitely if there are pending timers
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Verify the app renders - check for the MaterialApp title
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
