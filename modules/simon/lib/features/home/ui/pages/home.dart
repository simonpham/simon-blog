import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:panes/panes.dart';
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

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  final AuthViewModel _authViewModel = AuthViewModel();
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

  late final IdeController _controller = IdeController(
    leftSize: PaneSize.pixel(250),
    rightSize: PaneSize.pixel(250),
    bottomSize: PaneSize.pixel(150),
  );

  Listenable get _listenable => [CoreSettings.screenSize].of(SettingsBox());

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleSizeChanged);
    _postViewModel.loadPosts();
    _chatViewModel.init();

    // Set initial visibility states
    _isLeftPanelExpandedNotifier.value = true;
    _isRightPanelExpandedNotifier.value = false;
    _isBottomPanelExpandedNotifier.value = false;

    final currentPostId = widget.postId;
    if (currentPostId != null && currentPostId.isNotEmpty) {
      _postViewModel.openPost(currentPostId);
      return;
    }

    final currentPostSlug = widget.postSlug;
    if (currentPostSlug != null && currentPostSlug.isNotEmpty) {
      _postViewModel.openPost(currentPostSlug);
      return;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _handleSizeChanged();
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleSizeChanged);
    _postViewModel.dispose();
    _chatViewModel.dispose();
    _authViewModel.dispose();
    _controller.dispose();
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
      return;
    }

    final currentPostSlug = widget.postSlug;
    final currentLoadedPostSlug = _postViewModel.selectedPost?.data?.slug;
    if (currentPostSlug != null && currentLoadedPostSlug == currentPostSlug) {
      return;
    }

    if (currentPostSlug != null && oldWidget.postSlug != currentPostSlug) {
      _postViewModel.openPost(currentPostSlug);
      return;
    }
  }

  void _handleSizeChanged() {
    if (!context.mounted) {
      return;
    }
    final screenSize = MediaQuery.sizeOf(context);

    // The panes package handles visibility via callbacks, 
    // we just need to respond to window size changes appropriately
    if (screenSize.width < 800) {
      _controller.rootController.hide(IdePane.left.id);
      _isLeftPanelExpandedNotifier.value = false;
    } else if (!_isLeftPanelExpandedNotifier.value) {
      _controller.rootController.show(IdePane.left.id);
      _isLeftPanelExpandedNotifier.value = true;
    }

    if (screenSize.width < 600) {
      _controller.rootController.hide(IdePane.right.id);
      _isRightPanelExpandedNotifier.value = false;
    }
  }

  void _handlePaneStateChanged(IdePane pane, bool isVisible) {
    switch (pane) {
      case IdePane.left:
        _isLeftPanelExpandedNotifier.value = isVisible;
        break;
      case IdePane.right:
        _isRightPanelExpandedNotifier.value = isVisible;
        break;
      case IdePane.bottom:
        _isBottomPanelExpandedNotifier.value = isVisible;
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const dividerThickness = 1.0;
    final dividerColor = context.theme.dividerColor;
    final divider = Container(
      color: dividerColor,
      height: dividerThickness,
      width: double.infinity,
    );

    return ChangeNotifierProvider.value(
      value: _authViewModel,
      child: Scaffold(
        body: Column(
          children: [
            HeaderBar(
              onSearchTap: () {
                // Implement search functionality here
              },
            ),
            divider,
            Expanded(
              child: PaneTheme(
                data: PaneThemeData(
                  resizerColor: Colors.transparent,
                  resizerHoverColor: context.theme.colorScheme.primary,
                  resizerThickness: 1.0,
                ),
                child: IdeLayout(
                  controller: _controller,
                  onPaneStateChanged: _handlePaneStateChanged,
                leftPanelBuilder: (context) {
                  return ChangeNotifierProvider.value(
                    value: _postViewModel,
                    child: const PostBrowser(),
                  );
                },
                rightPanelBuilder: (context) {
                  return ChangeNotifierProvider.value(
                    value: _chatViewModel,
                    builder: (context, _) => const ChatPanel(),
                  );
                },
                bottomPanelBuilder: (context) {
                  return ChangeNotifierProvider.value(
                    value: _postViewModel,
                    builder: (context, _) => CommentPanel(
                      post: context.select<PostViewModel, Post?>(
                        (viewModel) => viewModel.selectedPost?.data,
                      ),
                    ),
                  );
                },
                centerBuilder: (context) {
                  return ChangeNotifierProvider.value(
                    value: _postViewModel,
                    child: const PostContent(),
                  );
                },
              ),
            ),
          ),
            divider,
            ChangeNotifierProvider.value(
              value: _postViewModel,
              builder: (context, model) {
                final currentMessage = context.select(
                  (PostViewModel model) => model.statusBarMessage,
                );
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
                      message: currentMessage,
                      onAction: (action) {
                        switch (action) {
                          case StatusBarAction.toggleLeftPanel:
                            _controller.toggleLeft();
                            break;
                          case StatusBarAction.toggleRightPanel:
                            _controller.toggleRight();
                            break;
                          case StatusBarAction.toggleBottomPanel:
                            _controller.toggleBottom();
                            break;
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
