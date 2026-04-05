import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wolfchat/features/home/viewmodels/home_viewmodel.dart';
import 'package:wolfchat/features/home/views/home_page.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/api_keys_modal.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/manage_models_modal.dart';
import 'package:wolfchat/features/home/views/widgets/dialogs/settings_modal.dart';
import 'package:wolfchat/features/search/viewmodels/search_viewmodel.dart';
import 'package:wolfchat/features/search/views/search_page.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'chat/:id',
            name: 'chat',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return CustomTransitionPage(
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                child: HomePage(conversationId: id),
              );
            },
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            pageBuilder: (context, state) => CustomTransitionPage(
              // ignore: avoid_redundant_argument_values, explicit configuration required for QA
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curvedAnimation,
                      child: child,
                    );
                  },
              child: Consumer<SearchViewModel>(
                builder: (context, viewModel, _) => const SearchPage(),
              ),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              opaque: false,
              barrierColor: Colors.black54,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, _) => SettingsModal(
                  viewModel: viewModel,
                  onClose: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('home');
                    }
                  },
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'api-keys',
                name: 'api-keys',
                pageBuilder: (context, state) => CustomTransitionPage(
                  opaque: false,
                  barrierColor: Colors.black54,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: Consumer<HomeViewModel>(
                    builder: (context, viewModel, _) => ApiKeysModal(
                      viewModel: viewModel,
                      onClose: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed('settings');
                        }
                      },
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: 'models',
                name: 'models',
                pageBuilder: (context, state) => CustomTransitionPage(
                  opaque: false,
                  barrierColor: Colors.black54,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: Consumer<HomeViewModel>(
                    builder: (context, viewModel, _) => ManageModelsModal(
                      viewModel: viewModel,
                      onClose: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed('settings');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
