import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

/// Dialog for creating or editing a post.
class PostEditorDialog extends StatefulWidget {
  /// The post to edit. If null, creates a new post.
  final Post? post;

  /// The author for new posts.
  final User author;

  const PostEditorDialog({
    super.key,
    this.post,
    required this.author,
  });

  /// Shows the dialog and returns true if the post was saved.
  static Future<bool> show(
    BuildContext context, {
    Post? post,
    required User author,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PostEditorDialog(
        post: post,
        author: author,
      ),
    );
    return result ?? false;
  }

  @override
  State<PostEditorDialog> createState() => _PostEditorDialogState();
}

class _PostEditorDialogState extends State<PostEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _summaryController;
  late final TextEditingController _tagsController;

  late PostVisibility _visibility;
  late PostStatus _status;

  bool _isSaving = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    _titleController = TextEditingController(text: post?.title ?? '');
    _contentController = TextEditingController(text: post?.content ?? '');
    _summaryController = TextEditingController(text: post?.summary ?? '');
    _tagsController = TextEditingController(
      text: post?.tags.join(', ') ?? '',
    );
    _visibility = post?.visibility ?? PostVisibility.private;
    _status = post?.status ?? PostStatus.draft;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> get _parsedTags {
    final tagsText = _tagsController.text.trim();
    if (tagsText.isEmpty) return [];
    return tagsText
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      context.toast('Title is required', type: MessageType.error);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final postViewModel = context.read<PostViewModel>();
      Failure? result;

      if (_isEditing) {
        result = await postViewModel.updateCurrentPost(
          title: _titleController.text.trim(),
          content: _contentController.text,
          summary: _summaryController.text.trim(),
          tags: _parsedTags,
          visibility: _visibility,
          status: _status,
        );
      } else {
        result = await postViewModel.createPost(
          title: _titleController.text.trim(),
          content: _contentController.text,
          summary: _summaryController.text.trim(),
          tags: _parsedTags,
          visibility: _visibility,
          status: _status,
          author: widget.author,
        );
      }

      if (!mounted) return;

      if (result != null) {
        context.toast(result.message, type: MessageType.error);
        setState(() => _isSaving = false);
        return;
      }

      context.navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      context.toast('Failed to save post: $e', type: MessageType.error);
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Post' : 'New Post'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter post title',
                ),
                autofocus: true,
              ),
              Spacing.v16,

              // Content
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content (Markdown)',
                  hintText: 'Write your post content here...',
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                minLines: 5,
              ),
              Spacing.v16,

              // Summary
              TextField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  hintText: 'Brief summary of the post (optional)',
                ),
                maxLines: 2,
              ),
              Spacing.v16,

              // Tags
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Comma-separated tags (e.g., flutter, dart)',
                ),
              ),
              Spacing.v16,

              // Visibility & Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visibility',
                          style: theme.textTheme.labelMedium,
                        ),
                        Spacing.v8,
                        DropdownButton<PostVisibility>(
                          value: _visibility,
                          isExpanded: true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _visibility = value);
                            }
                          },
                          items: PostVisibility.values
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v.name),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Spacing.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: theme.textTheme.labelMedium,
                        ),
                        Spacing.v8,
                        DropdownButton<PostStatus>(
                          value: _status,
                          isExpanded: true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                          items: PostStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          variant: ButtonVariant.ghost,
          onPressed: _isSaving ? null : () => context.navigator.pop(false),
          child: const Text('Cancel'),
        ),
        Button(
          variant: ButtonVariant.primary,
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(
                  _isEditing ? 'Save' : 'Create',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
        ),
      ],
    );
  }
}
