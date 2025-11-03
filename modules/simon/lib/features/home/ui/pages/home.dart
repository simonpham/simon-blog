import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:simon/simon.dart';

class HomePage extends StatefulWidget {
  static const String routePath = '/';
  static const String routeName = 'home';

  static void go(BuildContext context) {
    context.router.go(routePath);
  }

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IdeLayoutController controller = IdeLayoutController.create(
    leftPanel: (BuildContext context) {
      return const PostBrowser();
    },
    rightPanel: (BuildContext context) {
      return const ChatPanel();
    },
    bottomPanel: (BuildContext context) {
      return const CommentPanel();
    },
    content: (BuildContext context) {
      return const PostContent();
    },
  );

  Listenable get _listenable => [CoreSettings.screenSize].of(SettingsBox());

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleSizeChanged);
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleSizeChanged);
    super.dispose();
  }

  void _handleSizeChanged() {
    if (!context.mounted) {
      return;
    }
    final screenSize = MediaQuery.sizeOf(context);
    controller.handleWindowSizedChanged(screenSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IdeLayout(
        controller: controller,
        topBar: (BuildContext context) {
          return const HeaderBar();
        },
        bottomBar: (BuildContext context) {
          return const StatusBar();
        },
      ),
    );
  }
}
