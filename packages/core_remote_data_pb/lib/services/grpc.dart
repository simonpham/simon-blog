import 'dart:async';

import 'package:core/models/animals.dart';
import 'package:core/models/auth.dart';
import 'package:core/models/comment.dart';
import 'package:core/models/common/failure.dart';
import 'package:core/models/common/pagination.dart';
import 'package:core/models/post.dart';
import 'package:core/models/sidebar_post.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart' as pb;
import 'package:core_remote_data_pb/utils/decryptor.dart' as decryptor;
import 'package:core_remote_data_pb/utils/mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

class NowisPostApis implements PostApis {
  final pb.NowisServiceClient _client;

  final Completer<void> _healthCheckCompleter = Completer<void>();

  String _localAppId = '';
  String _localAppVersionRef = '';

  String _accessToken = '';

  void setAccessToken(String value) {
    _accessToken = value;
  }

  NowisPostApis({
    required String host,
    int? port,
  }) : _client = pb.NowisServiceClient(
         ClientChannel(
           host,
           port: port ?? 443,
           options: ChannelOptions(
             credentials: port != null
                 ? const ChannelCredentials.insecure()
                 : const ChannelCredentials.secure(),
             codecRegistry: CodecRegistry(
               codecs: [
                 const GzipCodec(),
               ],
             ),
           ),
         ),
       ) {
    _healthCheck();
  }

  Future<void> _waitForHealthCheck() async {
    if (!_healthCheckCompleter.isCompleted) {
      await _healthCheckCompleter.future;
    }

    if (_localAppId.isEmpty || _localAppVersionRef.isEmpty) {
      throw const Failure('Health check failed');
    }
  }

  Future<void> _healthCheck() async {
    if (_localAppId.isNotEmpty && _localAppVersionRef.isNotEmpty) {
      return;
    }

    final response = await _client.healthCheck(pb.HealthCheckRequest());
    if (response.appId.isEmpty || response.appVersionRef.isEmpty) {
      throw const Failure(
        'Health check failed',
      );
    }

    _localAppId = response.appId;
    _localAppVersionRef = response.appVersionRef;

    _healthCheckCompleter.complete();
  }

  @override
  FutureOr<Failure?> add(Post item) async {
    await _waitForHealthCheck();

    try {
      final status = switch (item.status) {
        PostStatus.draft => pb.PostStatus.draft,
        PostStatus.published => pb.PostStatus.published,
        PostStatus.archived => pb.PostStatus.archived,
      };

      final visibility = switch (item.visibility) {
        PostVisibility.public => pb.PostVisibility.public,
        PostVisibility.private => pb.PostVisibility.private,
        PostVisibility.unlisted => pb.PostVisibility.unlisted,
      };

      final response = await _client.createPost(
        pb.CreatePostRequest(
          title: item.title,
          content: item.content,
          summary: item.summary,
          featuredImageUrl: item.featuredImageUrl,
          status: status,
          visibility: visibility,
          tags: item.tags,
        ),
        options: CallOptions(
          metadata: {'authorization': 'Bearer $_accessToken'},
        ),
      );

      if (!response.hasPost()) {
        return const Failure('Failed to create post');
      }

      return null;
    } catch (e) {
      return Failure('Failed to create post: $e');
    }
  }

  @override
  FutureOr<Failure?> addAll(List<Post> items) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  FutureOr<int> count() {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  FutureOr<Failure?> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  FutureOr<Post?> get(String id) async {
    await _waitForHealthCheck();

    final response = await _client.getPostById(
      pb.GetPostByIdRequest(id: id),
    );

    if (!response.hasPost()) {
      return null;
    }
    final decryptedContent = await compute(
      decryptor.decrypt,
      {
        'encodedPayload': response.post.content,
        'appId': _localAppId,
        'appVersionRef': _localAppVersionRef,
      },
    );
    return response.post.toModel(decryptedContent);
  }

  @override
  FutureOr<Post?> getPostBySlug(String slug) async {
    await _waitForHealthCheck();

    final response = await _client.getPostBySlug(
      pb.GetPostBySlugRequest(slug: slug),
    );

    if (!response.hasPost()) {
      return null;
    }
    final decryptedContent = await compute(
      decryptor.decrypt,
      {
        'encodedPayload': response.post.content,
        'appId': _localAppId,
        'appVersionRef': _localAppVersionRef,
      },
    );
    return response.post.toModel(decryptedContent);
  }

  @override
  FutureOr<List<Post>> list(
    Pagination pagination, {
    String? searchQuery,
  }) async {
    await _waitForHealthCheck();

    final pagePagination = switch (pagination) {
      PagePagination pagination => pagination,
      _ => null,
    };
    final response = await _client.getPosts(
      pb.GetPostsRequest(
        limit: pagePagination?.pageSize,
        page: pagePagination?.page,
        searchQuery: searchQuery,
      ),
    );

    final List<Post> posts = [];
    for (final post in response.posts) {
      final decryptedContent = await compute(
        decryptor.decrypt,
        {
          'encodedPayload': post.content,
          'appId': _localAppId,
          'appVersionRef': _localAppVersionRef,
        },
      );
      posts.add(post.toModel(decryptedContent));
    }

    return posts;
  }

  @override
  FutureOr<Failure?> update(Post item) async {
    await _waitForHealthCheck();

    try {
      final status = switch (item.status) {
        PostStatus.draft => pb.PostStatus.draft,
        PostStatus.published => pb.PostStatus.published,
        PostStatus.archived => pb.PostStatus.archived,
      };

      final visibility = switch (item.visibility) {
        PostVisibility.public => pb.PostVisibility.public,
        PostVisibility.private => pb.PostVisibility.private,
        PostVisibility.unlisted => pb.PostVisibility.unlisted,
      };

      final response = await _client.updatePost(
        pb.UpdatePostRequest(
          postId: item.id,
          title: item.title,
          content: item.content,
          summary: item.summary,
          featuredImageUrl: item.featuredImageUrl,
          status: status,
          visibility: visibility,
          tags: item.tags,
        ),
        options: CallOptions(
          metadata: {'authorization': 'Bearer $_accessToken'},
        ),
      );

      if (!response.hasPost()) {
        return const Failure('Failed to update post');
      }

      return null;
    } catch (e) {
      return Failure('Failed to update post: $e');
    }
  }

  @override
  FutureOr<List<TagSidebar>> getSidebarPostsByTags({
    String? tagNameFilter,
  }) async {
    await _waitForHealthCheck();

    final response = await _client.getSidebarPostsByTags(
      pb.GetSidebarPostsByTagsRequest(
        tagNameFilter: tagNameFilter,
      ),
    );
    return response.tags.map((tag) => tag.toModel()).toList();
  }
}

class NowisCommentApis implements CommentApis {
  final pb.NowisServiceClient _client;

  NowisCommentApis({
    required String host,
    int? port,
  }) : _client = pb.NowisServiceClient(
         ClientChannel(
           host,
           port: port ?? 443,
           options: ChannelOptions(
             credentials: port != null
                 ? const ChannelCredentials.insecure()
                 : const ChannelCredentials.secure(),
             codecRegistry: CodecRegistry(
               codecs: [
                 const GzipCodec(),
               ],
             ),
           ),
         ),
       );

  @override
  FutureOr<Failure?> approveComment(String commentId) {
    // TODO: implement approveComment
    throw UnimplementedError();
  }

  @override
  FutureOr<Failure?> bulkApproveComments(List<String> commentIds) {
    // TODO: implement bulkApproveComments
    throw UnimplementedError();
  }

  @override
  FutureOr<Failure?> bulkDeleteComments(List<String> commentIds) {
    // TODO: implement bulkDeleteComments
    throw UnimplementedError();
  }

  @override
  FutureOr<Failure?> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  }) async {
    try {
      final response = await _client.createComment(
        pb.CreateCommentRequest(
          postId: postId,
          content: content,
          animal: animal.name,
          backgroundColor: backgroundColor.name,
        ),
      );

      if (!response.hasComment()) {
        return const Failure('Failed to create comment');
      }

      return null;
    } catch (e) {
      return Failure('Failed to create comment: $e');
    }
  }

  @override
  FutureOr<Failure?> deleteComment(String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      final response = await _client.getPostComments(
        pb.GetPostCommentsRequest(postId: postId),
      );

      return response.comments.map((e) => e.toModel()).toList();
    } catch (e) {
      throw Failure('Failed to fetch comments: $e');
    }
  }

  @override
  FutureOr<Failure?> updateComment({
    required String commentId,
    required String content,
  }) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }
}

class NowisAuthApis implements AuthApis {
  final pb.AuthServiceClient _client;

  NowisAuthApis({
    required String host,
    int? port,
  }) : _client = pb.AuthServiceClient(
         ClientChannel(
           host,
           port: port ?? 443,
           options: ChannelOptions(
             credentials: port != null
                 ? const ChannelCredentials.insecure()
                 : const ChannelCredentials.secure(),
             codecRegistry: CodecRegistry(
               codecs: [
                 const GzipCodec(),
               ],
             ),
           ),
         ),
       );

  @override
  FutureOr<AuthTokens?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.auth(
        pb.AuthRequest(
          username: username,
          password: password,
        ),
      );

      if (!response.success) {
        throw Failure(
          response.message.isEmpty ? 'Login failed' : response.message,
        );
      }

      return AuthTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
    } catch (e) {
      throw Failure('Login failed: $e');
    }
  }
}
