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
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
