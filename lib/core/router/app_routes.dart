import 'package:go_router/go_router.dart';
import 'package:portfolio/core/router/route_paths.dart';
import 'package:portfolio/presentation/home/home.dart';

final List<RouteBase> routes = [
  GoRoute(
    path: RoutePaths.home,
    builder: (context, state) => Home(),
  )
];
