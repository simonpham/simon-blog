import 'package:core/core.dart';
import 'package:simon/simon.dart';

final List<GoRoute> kSimonRoutes = [
  GoRoute(
    name: HomePage.routeName,
    path: HomePage.routePath,
    builder: (context, state) {
      final postId = switch (state.pathParameters) {
        {HomePage.identifierParam: String identifier} => identifier,
        _ => null,
      };
      return HomePage(postId: postId);
    },
  ),
  GoRoute(
    name: ErrorPage.routeName,
    path: ErrorPage.routePath,
    builder: (context, state) => const ErrorPage(),
  ),
];
