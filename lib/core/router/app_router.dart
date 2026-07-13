import 'package:go_router/go_router.dart';
import 'package:portfolio/presentation/home/tab_home.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => TabHome(),
      )
    ],
  );
}
