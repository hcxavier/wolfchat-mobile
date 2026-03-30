import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/core/di/service_locator.dart';
import 'package:wolfchat/core/router/app_router.dart';
import 'package:wolfchat/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: ServiceLocator.providers,
      child: const WolfChatApp(),
    ),
  );
}

class WolfChatApp extends StatelessWidget {
  const WolfChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WolfChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
