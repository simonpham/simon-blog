import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:simon/simon.dart';

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
      body: IdeLayout(
        topBar: (BuildContext context) {
          return const HeaderBar();
        },
        bottomBar: (BuildContext context) {
          return const SizedBox();
        },
        leftPanel: (BuildContext context) {
          return const SizedBox();
        },
        rightPanel: (BuildContext context) {
          return const SizedBox();
        },
        bottomPanel: (BuildContext context) {
          return const SizedBox();
        },
        content: (BuildContext context) {
          return const SizedBox();
        },
      ),
    );
  }
}
