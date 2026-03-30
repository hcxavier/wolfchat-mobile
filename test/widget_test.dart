import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/main.dart';
import 'package:wolfchat/core/di/service_locator.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: ServiceLocator.providers,
        child: const WolfChatApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('WolfChat'), findsOneWidget);
  });
}
