import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/post_api.dart';
import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';

class PostViewModel extends ChangeNotifier {
  PostApis get _postApis => injector.get<PostApis>();

  RxStatus<List<TagSidebar>> _tags = const RxStatus<List<TagSidebar>>();

  List<TagSidebar> get tags => _tags.data ?? const [];

  Pagination _nextPage = OffsetLimitPagination.initial();

  String? _currentTag = null;

  String? get currentTag => _currentTag;

  set currentTag(String? tag) {
    _currentTag = tag;
    notifyListeners();
  }

  RxStatus<Post>? _selectedPost;

  RxStatus<Post>? get selectedPost => _selectedPost;

  void refresh() {
    _nextPage = OffsetLimitPagination.initial();
    loadPosts();
  }

  void loadPosts() async {
    if (_tags.isLoading) {
      return;
    }

    try {
      _tags = _tags.copyWith(isLoading: true);
      notifyListeners();

      final tags = await _postApis.getSidebarPostsByTags(
        tagNameFilter: _currentTag,
      );
      if (tags.isEmpty) {
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

      _tags = _tags.copyWith(
        isLoading: false,
        data: Some([
          ...this.tags,
          ...tags,
        ]),
        error: const Some(null),
      );
      notifyListeners();
    } catch (err, trace) {
      printError(err, trace);
      _tags = _tags.copyWith(
        isLoading: false,
        error: Some(err.toString()),
      );
      notifyListeners();
    }
  }

  Future<void> openPost(String postIdentifier) async {
    _selectedPost = RxStatus.loading();
    notifyListeners();

    try {
      final isUuid = Uuid.isValidUUID(fromString: postIdentifier);
      final post = isUuid
          ? await _postApis.get(postIdentifier)
          : await _postApis.getPostBySlug(
              postIdentifier.replaceAll('.md', ''),
            );
      if (post == null) {
        _selectedPost = RxStatus.error('Post not found');
        notifyListeners();
        return;
      }

      _selectedPost = RxStatus.data(post);
      notifyListeners();
    } catch (err, trace) {
      printError(err, trace);
      _selectedPost = RxStatus.error('Failed to load post');
      notifyListeners();
    }
  }
}
