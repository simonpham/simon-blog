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
      role: Role.admin,
    ),
    User(
      id: 'default-user',
      email: 'mock.author@example.com',
      username: 'author',
      displayName: 'Author',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      role: Role.admin,
    ),
  ];

  @override
  FutureOr<Failure?> add(User item) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<Failure?> addAll(List<User> items) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<int> count() {
    return _user.length;
  }

  @override
  FutureOr<Failure?> delete(String id) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<User?> get(String id) {
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
  FutureOr<Failure?> update(User item) {
    return const UnauthorizedFailure();
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
      authorId: 'simon',
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
      authorId: 'default-user',
      tags: ['another', 'mock'],
      status: PostStatus.published,
      visibility: PostVisibility.public,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  FutureOr<Failure?> add(Post item) {
    _posts.add(item);
    return null;
  }

  @override
  FutureOr<Failure?> addAll(List<Post> items) {
    _posts.addAll(items);
    return null;
  }

  @override
  FutureOr<int> count() {
    return _posts.length;
  }

  @override
  FutureOr<Failure?> delete(String id) {
    _posts.removeWhere((post) => post.id == id);
    return null;
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
  FutureOr<Failure?> update(Post item) {
    final index = _posts.indexWhere((post) => post.id == item.id);
    if (index != -1) {
      _posts[index] = item;
      return null;
    }
    return const PostNotFoundFailure('Failed to update post');
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
  FutureOr<Failure?> approveComment(String commentId) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<Failure?> bulkApproveComments(List<String> commentIds) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<Failure?> bulkDeleteComments(List<String> commentIds) {
    return const UnauthorizedFailure();
  }

  @override
  FutureOr<Failure?> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  }) {
    _comments.add(
      Comment(
        id: kUuid.v4(),
        content: content,
        animal: Animals.sheep,
        backgroundColor: BackgroundColorType.red,
        postId: postId,
        createdAt: DateTime.now(),
      ),
    );
    return null;
  }

  @override
  FutureOr<Failure?> deleteComment(String commentId) {
    return const UnauthorizedFailure();
  }

  @override
  Future<List<Comment>> getCommentsForPost(String postId) async {
    return _comments.where((comment) => comment.postId == postId).toList();
  }

  @override
  FutureOr<Failure?> updateComment({
    required String commentId,
    required String content,
  }) {
    return const UnauthorizedFailure();
  }
}
