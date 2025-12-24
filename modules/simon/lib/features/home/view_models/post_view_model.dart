import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/post_api.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:simon/simon.dart';
import 'package:utils/utils.dart';

class PostViewModel extends ChangeNotifier {
  PostApis get _postApis => injector.get<PostApis>();

  RxStatus<List<TagSidebar>> _tags = const RxStatus<List<TagSidebar>>();

  List<TagSidebar> get tags => _tags.data ?? const [];

  Pagination _nextPage = OffsetLimitPagination.initial();

  String? _currentTag;

  String? get currentTag => _currentTag;

  set currentTag(String? tag) {
    _currentTag = tag;
    notifyListeners();
  }

  RxStatus<Post>? _selectedPost;

  RxStatus<Post>? get selectedPost => _selectedPost;

  StatusBarMessage? _statusBarMessage;

  StatusBarMessage? get statusBarMessage => _statusBarMessage;

  // Edit mode state
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  Post? _editingPost;
  Post? get editingPost => _editingPost;

  User? _editingAuthor;
  User? get editingAuthor => _editingAuthor;

  /// Starts editing a post. If post is null, creates a new post.
  void startEditing({Post? post, required User author}) {
    _isEditing = true;
    _editingPost = post;
    _editingAuthor = author;
    notifyListeners();
  }

  /// Cancels editing mode without saving.
  void cancelEditing() {
    _isEditing = false;
    _editingPost = null;
    _editingAuthor = null;
    notifyListeners();
  }


  void refresh() {
    _nextPage = OffsetLimitPagination.initial();
    loadPosts();
  }

  void loadPosts() async {
    if (_tags.isLoading) {
      return;
    }

    try {
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.info,
        message: 'Loading posts...',
      );
      _tags = _tags.copyWith(isLoading: true);
      notifyListeners();

      final tags = await _postApis.getSidebarPostsByTags(
        tagNameFilter: _currentTag,
      );
      if (tags.isEmpty) {
        _statusBarMessage = null;
        _tags = _tags.copyWith(
          isLoading: false,
        );
        notifyListeners();
        return;
      }

      if (_nextPage case OffsetLimitPagination pagination) {
        _nextPage = OffsetLimitPagination(
          offset: pagination.offset + pagination.limit,
          limit: pagination.limit,
        );
      }

      _statusBarMessage = null;
      _tags = _tags.copyWith(
        isLoading: false,
        data: Some(
          [
            ...this.tags,
            ...tags,
          ]..sort((a, b) => a.tagName.compareTo(b.tagName)),
        ),
        error: const Some(null),
      );
      notifyListeners();
    } catch (err, trace) {
      printError(err, trace);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.error,
        message: 'Failed to load posts',
      );
      _tags = _tags.copyWith(
        isLoading: false,
        error: Some(err.toString()),
      );
      notifyListeners();
    }
  }

  Future<void> openPost(String postIdentifier) async {
    _selectedPost = RxStatus.loading();
    _statusBarMessage = const StatusBarMessage(
      type: MessageType.info,
      message: 'Loading post...',
    );
    notifyListeners();

    try {
      final isUuid = Uuid.isValidUUID(fromString: postIdentifier);
      final post = isUuid
          ? await _postApis.get(postIdentifier)
          : await _postApis.getPostBySlug(
              postIdentifier.replaceAll('.md', ''),
            );
      if (post == null) {
        _statusBarMessage = const StatusBarMessage(
          type: MessageType.error,
          message: 'Post not found',
        );
        _selectedPost = RxStatus.error('Post not found');
        notifyListeners();
        return;
      }

      _statusBarMessage = null;
      _selectedPost = RxStatus.data(post);
      notifyListeners();
    } catch (err, trace) {
      printError(err, trace);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.error,
        message: 'Failed to load post',
      );
      _selectedPost = RxStatus.error('Failed to load post');
      notifyListeners();
    }
  }

  /// Creates a new post (admin only).
  Future<Failure?> createPost({
    required String title,
    required String content,
    required User author,
    String summary = '',
    List<String> tags = const [],
    PostVisibility visibility = PostVisibility.private,
    PostStatus status = PostStatus.draft,
  }) async {
    _statusBarMessage = const StatusBarMessage(
      type: MessageType.info,
      message: 'Creating post...',
    );
    notifyListeners();

    try {
      final newPost = Post.newPost(
        title: title,
        content: content,
        summary: summary,
        author: author,
        tags: tags,
        visibility: visibility,
        status: status,
      );

      final createdPost = await _postApis.createPost(newPost);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.success,
        message: 'Post created successfully',
      );
      _selectedPost = RxStatus.data(createdPost);
      notifyListeners();

      // Refresh posts list
      refresh();
      return null;
    } catch (err, trace) {
      printError(err, trace);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.error,
        message: 'Failed to create post',
      );
      notifyListeners();
      return Failure('Failed to create post: $err');
    }
  }

  /// Updates an existing post (admin only).
  Future<Failure?> updateCurrentPost({
    String? title,
    String? content,
    String? summary,
    List<String>? tags,
    PostVisibility? visibility,
    PostStatus? status,
  }) async {
    final currentPost = _selectedPost?.data;
    if (currentPost == null) {
      return const Failure('No post selected');
    }

    _statusBarMessage = const StatusBarMessage(
      type: MessageType.info,
      message: 'Saving post...',
    );
    notifyListeners();

    try {
      final updatedPost = currentPost.copyWith(
        title: title,
        content: content,
        summary: summary,
        tags: tags,
        visibility: visibility,
        status: status,
      );

      final savedPost = await _postApis.updatePost(updatedPost);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.success,
        message: 'Post saved successfully',
      );
      _selectedPost = RxStatus.data(savedPost);
      notifyListeners();

      // Refresh posts list
      refresh();
      return null;
    } catch (err, trace) {
      printError(err, trace);
      _statusBarMessage = const StatusBarMessage(
        type: MessageType.error,
        message: 'Failed to save post',
      );
      notifyListeners();
      return Failure('Failed to save post: $err');
    }
  }
}
