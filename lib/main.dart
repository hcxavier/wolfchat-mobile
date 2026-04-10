import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wolfchat/core/di/service_locator.dart';
import 'package:wolfchat/core/router/app_router.dart';
import 'package:wolfchat/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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

// Pseudo-update for commit 32 at 2026-04-09 07:03:05

// Pseudo-update for commit 38 at 2026-04-10 13:35:49

// Pseudo-update for commit 39 at 2026-04-10 18:41:16
