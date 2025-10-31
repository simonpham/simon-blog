import 'package:core/core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const String routePath = '/';
  static const String routeName = 'home';

  static void go(BuildContext context) {
    context.router.go(routePath);
  }

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simon'),
      ),
      body: const Center(
        child: Text('Simon'),
      ),
    );
  }
}
