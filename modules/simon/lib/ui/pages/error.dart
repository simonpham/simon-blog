import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class ErrorPage extends StatelessWidget {
  static const String routePath = '/error';
  static const String routeName = 'error';

  const ErrorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Button(
          variant: ButtonVariant.primary,
          label: 'Go to home',
          onPressed: () => HomePage.go(context),
        ),
      ),
    );
  }
}
