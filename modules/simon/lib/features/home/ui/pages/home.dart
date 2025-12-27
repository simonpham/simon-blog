import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons/icons.dart';
import 'package:panes/panes.dart';
import 'package:simon/features/search/view_models/search_view_model.dart';
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
  final SearchViewModel _searchViewModel = SearchViewModel();

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
    leftMinSize: PaneSize.pixel(150),
    leftMaxSize: PaneSize.pixel(500),
    rightSize: PaneSize.pixel(300),
    rightMinSize: PaneSize.pixel(150),
    rightMaxSize: PaneSize.pixel(500),
    bottomSize: PaneSize.pixel(240),
    bottomMinSize: PaneSize.pixel(38),
    bottomMaxSize: PaneSize.pixel(480),
  );

  Listenable get _listenable => [CoreSettings.screenSize].of(SettingsBox());

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleSizeChanged);
    _postViewModel.loadPosts();
    _postViewModel.addListener(_handleEditingChanged);
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

  /// Auto-show right pane when entering edit mode
  void _handleEditingChanged() {
    if (_postViewModel.isEditing) {
      _controller.rootController.show(IdePane.right.id);
      _isRightPanelExpandedNotifier.value = true;
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleSizeChanged);
    _postViewModel.removeListener(_handleEditingChanged);
    _postViewModel.dispose();
    _chatViewModel.dispose();
    _authViewModel.dispose();
    _searchViewModel.dispose();
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

  void _handleSearch() {
    SearchDialog.show<Post>(
      context,
      searchIcon: Assets.search,
      hintText: 'Sniffing out files and content...',
      onSearch: _searchViewModel.search,
      onItemSelected: (post) {
        HomePage.goToPost(context, identifier: post.fileName);
      },
      itemBuilder: (context, post, isSelected) {
        final theme = context.themeConfigs;
        final isDark = context.theme.brightness == Brightness.dark;

        return Row(
          children: [
            Container(
              width: Spacing.d40,
              height: Spacing.d40,
              decoration: BoxDecoration(
                color: isDark ? theme.colors.neutral6 : theme.colors.neutral2,
                borderRadius: Spacing.smoothR8,
              ),
              alignment: Alignment.center,
              child: ImageView(
                Assets.bookOpen01,
                size: Spacing.d24,
                color: isDark ? theme.colors.neutral3 : theme.colors.neutral5,
              ),
            ),
            Spacing.horizontal(Spacing.d12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.title,
                    style: theme.typography.base1.copyWith(
                      color: isSelected
                          ? theme.colors.primary
                          : (isDark
                                ? theme.colors.neutral1
                                : theme.colors.neutral7),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.summary.isNotEmpty) ...[
                    Spacing.v4,
                    Text(
                      post.summary,
                      style: theme.typography.caption1.copyWith(
                        color: theme.colors.neutral4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Spacing.h8,
            if (isSelected) ...[
              ImageView(
                Assets.link04,
                size: Spacing.d16,
                color: theme.colors.primary,
              ),
            ],
          ],
        );
      },
    );
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

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          _handleSearch();
        },
      },
      child: ChangeNotifierProvider.value(
        value: _authViewModel,
        child: Scaffold(
          body: Column(
            children: [
              HeaderBar(
                onSearchTap: _handleSearch,
              ),
              divider,
              Expanded(
                child: PaneTheme(
                  data: PaneThemeData(
                    resizerColor: context.theme.dividerColor,
                    resizerHoverColor: context.theme.colorScheme.primary,
                    resizerThickness: 1.0,
                    resizerHitTestThickness: 1.0,
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
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: _postViewModel),
                          ChangeNotifierProvider.value(value: _chatViewModel),
                        ],
                        child: const _RightPanelContent(),
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
      ),
    );
  }
}

/// Right panel content that shows metadata + chat when editing,
/// or just chat when viewing.
class _RightPanelContent extends StatefulWidget {
  const _RightPanelContent();

  @override
  State<_RightPanelContent> createState() => _RightPanelContentState();
}

class _RightPanelContentState extends State<_RightPanelContent> {
  static const _metadataPaneId = 'metadata';
  static const _chatPaneId = 'chat';

  late final PaneController _paneController;

  @override
  void initState() {
    super.initState();
    _paneController = PaneController(
      entries: [
        PaneEntry(id: _metadataPaneId, initialSize: PaneSize.fraction(0.4)),
        PaneEntry(id: _chatPaneId, initialSize: PaneSize.fraction(0.6)),
      ],
    );
  }

  @override
  void dispose() {
    _paneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = context.select<PostViewModel, bool>(
      (vm) => vm.isEditing,
    );

    // When not editing, just show the chat panel
    if (!isEditing) {
      return const ChatPanel();
    }

    // When editing, split between metadata and chat
    return MultiPane(
      direction: Axis.vertical,
      controller: _paneController,
      paneBuilder: (context, paneId) {
        return switch (paneId) {
          _metadataPaneId => const PostMetadataPanel(),
          _chatPaneId => const ChatPanel(),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
