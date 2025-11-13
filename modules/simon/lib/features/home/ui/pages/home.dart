import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:simon/simon.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'home';
  static const String routePath = '/:$identifierParam';

  static const String identifierParam = 'identifier';

  final String? postId;
  final String? postSlug;

  static void go(BuildContext context) {
    context.router.goNamed(routeName);
  }

  static void goToPost(
    BuildContext context, {
    required String identifier,
  }) {
    context.router.goNamed(
      routeName,
      pathParameters: {
        identifierParam: identifier,
      },
    );
  }

  const HomePage({
    super.key,
    this.postId,
    this.postSlug,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostViewModel _postViewModel = PostViewModel();
  final ChatViewModel _chatViewModel = ChatViewModel();

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
      return ChangeNotifierProvider.value(
        value: _chatViewModel,
        builder: (context, _) => const ChatPanel(),
      );
    },
    bottomPanel: (BuildContext context) {
      return ChangeNotifierProvider.value(
        value: _postViewModel,
        builder: (context, _) => CommentPanel(
          post: context.select<PostViewModel, Post?>(
            (viewModel) => viewModel.selectedPost?.data,
          ),
        ),
      );
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
    _chatViewModel.init();

    final currentPostId = widget.postId;
    if (currentPostId != null && currentPostId.isNotEmpty) {
      _postViewModel.openPost(currentPostId);
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleSizeChanged);
    _postViewModel.dispose();
    _chatViewModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentPostId = widget.postId;
    final currentLoadedPostId = _postViewModel.selectedPost?.data?.id;
    if (currentPostId != null && currentLoadedPostId == currentPostId) {
      return;
    }
    if (currentPostId != null && oldWidget.postId != currentPostId) {
      _postViewModel.openPost(currentPostId);
    }
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
          return HeaderBar(
            onSearchTap: () {
              // Implement search functionality here
            },
          );
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
