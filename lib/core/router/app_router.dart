import 'package:go_router/go_router.dart';
import 'package:wolfchat/features/home/views/home_page.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
