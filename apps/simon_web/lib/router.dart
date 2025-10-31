import 'package:core/core.dart';
import 'package:simon/simon.dart';

final GoRouter kAppRouter = GoRouter(
  initialLocation: HomePage.routePath,
  errorBuilder: (_, _) => const ErrorPage(),
  routes: [
    ...kSimonRoutes,
  ],
);
