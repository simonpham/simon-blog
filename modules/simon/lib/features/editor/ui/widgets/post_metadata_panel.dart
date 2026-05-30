import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:simon/simon.dart';

/// Right panel for editing post metadata (summary, tags, visibility, status).
class PostMetadataPanel extends StatefulWidget {
  const PostMetadataPanel({super.key});

  @override
  State<PostMetadataPanel> createState() => _PostMetadataPanelState();
}

class _PostMetadataPanelState extends State<PostMetadataPanel> {
  late final TextEditingController _summaryController;
  late final TextEditingController _tagsController;

  late PostVisibility _visibility;
  late PostStatus _status;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final postViewModel = context.read<PostViewModel>();
    final post = postViewModel.editingPost;

    _summaryController = TextEditingController(text: post?.summary ?? '');
    _tagsController = TextEditingController(
      text: post?.tags.join(', ') ?? '',
    );
    _visibility = post?.visibility ?? PostVisibility.private;
    _status = post?.status ?? PostStatus.draft;
  }

  @override
  void dispose() {
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
    // Get editor data from PostEditor
    final editorData = PostEditor.getEditorData();
    if (editorData == null) {
      context.toast('Unable to get editor data', type: MessageType.error);
      return;
    }

    if (editorData.title.isEmpty) {
      context.toast('Title is required', type: MessageType.error);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final postViewModel = context.read<PostViewModel>();
      final isEditing = postViewModel.editingPost != null;
      Failure? result;

      if (isEditing) {
        result = await postViewModel.updateCurrentPost(
          title: editorData.title,
          content: editorData.content,
          summary: _summaryController.text.trim(),
          tags: _parsedTags,
          visibility: _visibility,
          status: _status,
        );
      } else {
        final author = postViewModel.editingAuthor;
        if (author == null) {
          context.toast('Author not found', type: MessageType.error);
          setState(() => _isSaving = false);
          return;
        }
        result = await postViewModel.createPost(
          title: editorData.title,
          content: editorData.content,
          summary: _summaryController.text.trim(),
          tags: _parsedTags,
          visibility: _visibility,
          status: _status,
          author: author,
        );
      }

      if (!mounted) return;

      if (result != null) {
        context.toast(result.message, type: MessageType.error);
        setState(() => _isSaving = false);
        return;
      }

      // Success - exit edit mode
      postViewModel.cancelEditing();
    } catch (e) {
      if (!mounted) return;
      context.toast('Failed to save post: $e', type: MessageType.error);
      setState(() => _isSaving = false);
    }
  }

  void _handleCancel() {
    context.read<PostViewModel>().cancelEditing();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isEditing = context.select<PostViewModel, bool>(
      (vm) => vm.editingPost != null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaneTabBar(
          children: [
            PaneTabItem(
              label: isEditing ? 'Edit Post' : 'New Post',
              icon: Assets.pencilEdit02,
            ),
          ],
        ),
        const Divider(height: 1.0),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Spacing.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary
                _buildLabel('Summary', theme),
                Spacing.v8,
                InputText(
                  controller: _summaryController,
                  hintText: 'Brief summary (optional)',
                  maxLines: 3,
                ),
                Spacing.v16,

                // Tags
                _buildLabel('Tags', theme),
                Spacing.v8,
                InputText(
                  controller: _tagsController,
                  hintText: 'Comma-separated tags',
                ),
                Spacing.v16,

                // Visibility
                _buildLabel('Visibility', theme),
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
                Spacing.v16,

                // Status
                _buildLabel('Status', theme),
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
        ),
        // Actions
        Container(
          padding: EdgeInsets.all(Spacing.d16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.ghost,
                  onPressed: _isSaving ? null : _handleCancel,
                  child: const Text('Cancel'),
                ),
              ),
              Spacing.h8,
              Expanded(
                child: Button(
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
                          isEditing ? 'Save' : 'Create',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
