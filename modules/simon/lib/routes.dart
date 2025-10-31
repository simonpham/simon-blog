import 'package:core/core.dart';
import 'package:simon/simon.dart';

final List<GoRoute> kSimonRoutes = [
  GoRoute(
    name: HomePage.routeName,
    path: HomePage.routePath,
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    name: ErrorPage.routeName,
    path: ErrorPage.routePath,
    builder: (context, state) => const ErrorPage(),
  ),
];
