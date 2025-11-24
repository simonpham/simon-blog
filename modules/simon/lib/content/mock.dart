import 'dart:async';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:utils/utils.dart';

part 'mock_content.dart';

class MockUserApis implements UserApis {
  final List<User> _user = [
    User(
      id: 'simon',
      email: 'simon@sofluffy.io',
      username: 'simon',
      displayName: 'Simon',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'default-user',
      email: 'mock.author@example.com',
      username: 'author',
      displayName: 'Author',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  FutureOr<User> add(User item) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<List<User>> addAll(List<User> items) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<int> count() {
    return _user.length;
  }

  @override
  FutureOr<void> delete(String id) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<User?> get(String id) async {
    return _user.firstWhereOrNull((user) => user.id == id);
  }

  @override
  FutureOr<List<User>> list(
    Pagination pagination, {
    String? searchQuery,
  }) {
    return _user.toList();
  }

  @override
  FutureOr<User> update(User item) {
    throw const UnauthorizedFailure();
  }
}

class MockAuthApis implements AuthApis {
  @override
  FutureOr<AuthTokens?> login({
    required String username,
    required String password,
  }) {
    if (username == 'simon' && password == 'password') {
      return AuthTokens(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
      );
    }
    return null;
  }
}

class MockPostApis implements PostApis {
  final List<Post> _posts = [
    Post(
      id: 'post-1',
      title: _mockTitle,
      slug: _mockSlug,
      content: _mockContent,
      summary: _mockSummary,
      author: User(
        id: 'simon',
        username: 'simon',
        email: 'simon@sofluffy.io',
        displayName: 'Simon',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      tags: _mockTags,
      featuredImageUrl: _mockCoverImage,
      status: PostStatus.published,
      visibility: PostVisibility.public,
      createdAt: _mockPublishedAt,
      updatedAt: _mockPublishedAt,
    ),
    Post(
      id: 'post-2',
      title: 'Another Mock Post Title',
      slug: 'another-mock-post-title',
      content: 'Another Mock Post Content',
      summary: 'Another Mock Post Summary',
      author: User(
        id: 'default-user',
        username: 'author',
        email: 'mock.author@example.com',
        displayName: 'Author',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      tags: ['another', 'mock'],
      status: PostStatus.published,
      visibility: PostVisibility.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  FutureOr<Post> add(Post item) {
    _posts.add(item);
    return item;
  }

  @override
  FutureOr<List<Post>> addAll(List<Post> items) {
    _posts.addAll(items);
    return items;
  }

  @override
  FutureOr<int> count() {
    return _posts.length;
  }

  @override
  FutureOr<void> delete(String id) {
    _posts.removeWhere((post) => post.id == id);
  }

  @override
  FutureOr<Post?> get(String id) {
    return _posts.firstWhereOrNull((post) => post.id == id);
  }

  @override
  FutureOr<List<Post>> list(
    Pagination pagination, {
    String? searchQuery,
  }) {
    if (pagination is! OffsetLimitPagination) {
      return _posts.toList();
    }

    final currentPosition = pagination.offset;
    final nextPosition = currentPosition + pagination.limit;

    if (currentPosition >= _posts.length) {
      return [];
    }

    if (nextPosition > _posts.length) {
      return _posts.sublist(currentPosition);
    }

    return _posts.sublist(
      pagination.offset,
      pagination.offset + pagination.limit,
    );
  }

  @override
  FutureOr<Post> update(Post item) {
    final index = _posts.indexWhere((post) => post.id == item.id);
    if (index != -1) {
      _posts[index] = item;
      return item;
    }
    throw const PostNotFoundFailure('Failed to update post');
  }

  @override
  FutureOr<Post?> getPostBySlug(String slug) {
    return null;
  }

  @override
  FutureOr<List<TagSidebar>> getSidebarPostsByTags({
    String? tagNameFilter,
  }) {
    return [];
  }
}

class MockCommentApis implements CommentApis {
  final List<Comment> _comments = [];

  @override
  FutureOr<Comment> approveComment(String commentId) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<void> bulkApproveComments(List<String> commentIds) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<void> bulkDeleteComments(List<String> commentIds) {
    throw const UnauthorizedFailure();
  }

  @override
  FutureOr<Comment> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  }) {
    final comment = Comment(
      id: kUuid.v4(),
      content: content,
      animal: animal,
      backgroundColor: backgroundColor,
      postId: postId,
      createdAt: DateTime.now(),
    );
    _comments.add(comment);
    return comment;
  }

  @override
  FutureOr<void> deleteComment(String commentId) {
    throw const UnauthorizedFailure();
  }

  @override
  Future<List<Comment>> getCommentsForPost(String postId) async {
    return _comments.where((comment) => comment.postId == postId).toList();
  }

  @override
  FutureOr<Comment> updateComment({
    required String commentId,
    required String content,
  }) {
    throw const UnauthorizedFailure();
  }
}
