import 'package:core/core.dart';
import 'package:simon/simon.dart';

const _defaultLocation = '/welcome.md';

final GoRouter kAppRouter = GoRouter(
  initialLocation: _defaultLocation,
  errorBuilder: (_, _) => const ErrorPage(),
  redirect: (context, state) {
    final postId = switch (state.pathParameters) {
      {HomePage.identifierParam: String identifier} => identifier,
      _ => null,
    };
    if (postId == null) {
      return _defaultLocation;
    }
    return null;
  },
  routes: [
    ...kSimonRoutes,
  ],
);
