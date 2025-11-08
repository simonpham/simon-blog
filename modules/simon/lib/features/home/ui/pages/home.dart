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
  final PostViewModel _postViewModel = PostViewModel();

  final ValueNotifier<bool> _isLeftPanelExpandedNotifier = ValueNotifier<bool>(
    true,
  );
  final ValueNotifier<bool> _isRightPanelExpandedNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> _isBottomPanelExpandedNotifier =
      ValueNotifier<bool>(
        false,
      );

  late final IdeLayoutController controller = IdeLayoutController.create(
    onPanelStateChanged: (IdePanel panel, bool isExpanded) {
      switch (panel) {
        case IdePanel.leftPanel:
          _isLeftPanelExpandedNotifier.value = isExpanded;
          break;
        case IdePanel.rightPanel:
          _isRightPanelExpandedNotifier.value = isExpanded;
          break;
        case IdePanel.bottomPanel:
          _isBottomPanelExpandedNotifier.value = isExpanded;
          break;
      }
    },
    leftPanel: (BuildContext context) {
      return ChangeNotifierProvider.value(
        value: _postViewModel,
        child: const PostBrowser(),
      );
    },
    rightPanel: (BuildContext context) {
      return const ChatPanel();
    },
    bottomPanel: (BuildContext context) {
      return const CommentPanel();
    },
    content: (BuildContext context) {
      return ChangeNotifierProvider.value(
        value: _postViewModel,
        child: const PostContent(),
      );
    },
  );

  Listenable get _listenable => [CoreSettings.screenSize].of(SettingsBox());

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleSizeChanged);
    _postViewModel.loadPosts();
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleSizeChanged);
    _postViewModel.dispose();
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
          return MultiValueListenableBuilder(
            listenables: [
              _isLeftPanelExpandedNotifier,
              _isRightPanelExpandedNotifier,
              _isBottomPanelExpandedNotifier,
            ],
            builder: (context) {
              return StatusBar(
                isLeftPanelOpen: _isLeftPanelExpandedNotifier.value,
                isRightPanelOpen: _isRightPanelExpandedNotifier.value,
                isBottomPanelOpen: _isBottomPanelExpandedNotifier.value,
                onAction: (action) {
                  switch (action) {
                    case StatusBarAction.toggleLeftPanel:
                      controller.toggle(IdePanel.leftPanel);
                      break;
                    case StatusBarAction.toggleRightPanel:
                      controller.toggle(IdePanel.rightPanel);
                      break;
                    case StatusBarAction.toggleBottomPanel:
                      controller.toggle(IdePanel.bottomPanel);
                      break;
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
