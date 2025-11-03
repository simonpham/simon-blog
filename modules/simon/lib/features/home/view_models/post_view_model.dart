import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/post_api.dart';
import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';

class PostViewModel extends ChangeNotifier {
  PostApis get _postApis => injector.get<PostApis>();

  RxStatus<List<Post>> _posts = const RxStatus<List<Post>>();

  List<Post> get posts => _posts.data ?? const [];

  Pagination _nextPage = OffsetLimitPagination.initial();

  Post? _selectedPost;

  Post? get selectedPost => _selectedPost;

  void selectPost(Post post) {
    _selectedPost = post;
    notifyListeners();
  }

  void refresh() {
    _nextPage = OffsetLimitPagination.initial();
    loadPosts();
  }

  void loadPosts() async {
    if (_posts.isLoading) {
      return;
    }

    try {
      _posts = _posts.copyWith(isLoading: true);
      notifyListeners();

      final posts = await _postApis.list(_nextPage);
      if (posts.isEmpty) {
        _posts = _posts.copyWith(
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

      _posts = _posts.copyWith(
        isLoading: false,
        data: Some([
          ...this.posts,
          ...posts,
        ]),
        error: const Some(null),
      );
      notifyListeners();
    } catch (err, trace) {
      printError(err, trace);
      _posts = _posts.copyWith(
        isLoading: false,
        error: Some(err.toString()),
      );
      notifyListeners();
    }
  }
}
