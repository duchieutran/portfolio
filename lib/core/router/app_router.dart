import 'package:go_router/go_router.dart';
import 'package:portfolio/core/router/app_routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: routes,
  );
}
