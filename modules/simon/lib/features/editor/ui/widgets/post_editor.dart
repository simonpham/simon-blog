import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:panes/panes.dart';
import 'package:simon/simon.dart';
import 'package:ui_markdown/ui_markdown.dart';

/// In-place editor widget with split-view layout.
/// Left side: raw markdown editor, Right side: live preview.
/// Uses MultiPane for resizable split.
class PostEditor extends StatefulWidget {
  /// Global key to access editor data from parent widgets.
  static final GlobalKey<_PostEditorState> editorKey =
      GlobalKey<_PostEditorState>();

  const PostEditor({super.key});

  /// Gets the current editor values for saving.
  static PostEditorData? getEditorData() {
    final state = editorKey.currentState;
    if (state == null) return null;
    return PostEditorData(
      title: state._titleController.text.trim(),
      content: state._contentController.text,
    );
  }

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  // Independent scroll controllers for each pane
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();

  // Pane controller for resizable split
  late final PaneController _paneController;

  static const _editorPaneId = 'editor';
  static const _previewPaneId = 'preview';

  @override
  void initState() {
    super.initState();
    final postViewModel = context.read<PostViewModel>();
    final post = postViewModel.editingPost;

    _titleController = TextEditingController(text: post?.title ?? '');
    _contentController = TextEditingController(text: post?.content ?? '');

    // Initialize pane controller with 50/50 split
    _paneController = PaneController(
      entries: [
        PaneEntry(id: _editorPaneId, initialSize: PaneSize.fraction(0.5)),
        PaneEntry(id: _previewPaneId, initialSize: PaneSize.fraction(0.5)),
      ],
    );

    // Listen for changes to update preview
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _editorScrollController.dispose();
    _previewScrollController.dispose();
    _paneController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {});
  }

  String get _previewContent {
    final title = _titleController.text;
    final content = _contentController.text;
    final headerBlock = title.isNotEmpty ? '# $title\n\n' : '';
    return '$headerBlock$content';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return MultiPane(
      direction: Axis.horizontal,
      controller: _paneController,
      paneBuilder: (context, paneId) {
        return switch (paneId) {
          _editorPaneId => _buildEditorPane(theme),
          _previewPaneId => _buildPreviewPane(theme),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildEditorPane(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(theme, 'Editor', Assets.pencilEdit02),
          // Title field
          Padding(
            padding: EdgeInsets.all(Spacing.d16),
            child: InputText(
              controller: _titleController,
              hintText: 'Post title...',
              textStyle: theme.textTheme.headlineSmall,
              maxLines: 1,
              decorationBuilder: (_, __, ___, ____) => const BoxDecoration(),
              inputPadding: EdgeInsets.zero,
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          // Content editor with scrolling
          Expanded(
            child: SingleChildScrollView(
              controller: _editorScrollController,
              padding: EdgeInsets.all(Spacing.d16),
              child: TextField(
                controller: _contentController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: kCodeFontFamily,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your content in Markdown...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPane(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(theme, 'Preview', Assets.bookOpen01),
          // Markdown preview
          Expanded(
            child: SingleChildScrollView(
              controller: _previewScrollController,
              child: MarkdownContent(_previewContent, shrinkWrap: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title, String icon) {
    return Container(
      height: Spacing.d32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
          // Tab-style header like EditorHeader
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
            alignment: Alignment.center,
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Container(
                      width: Spacing.d16,
                      height: Spacing.d16,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: Spacing.d8),
                      child: ImageView(
                        icon,
                        size: Spacing.d16,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  TextSpan(text: title),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Fill remaining space with border
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1.0,
                color: theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class to hold editor values for saving.
class PostEditorData {
  final String title;
  final String content;

  const PostEditorData({
    required this.title,
    required this.content,
  });
}
