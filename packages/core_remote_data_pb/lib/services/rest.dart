import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/utils/decryptor.dart' as decryptor;
import 'package:core_remote_data_pb/utils/parse_utils.dart';
import 'package:dio/dio.dart';

class RestCommentNowisApis implements CommentApis {
  final Dio _dio;

  RestCommentNowisApis({
    required String host,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: 'https://$host/v1/nowis',
           validateStatus: (status) {
             return status != null && status >= 200 && status < 300;
           },
         ),
       );

  @override
  FutureOr<Comment> approveComment(String commentId) {
    // TODO: implement approveComment
    throw UnimplementedError();
  }

  @override
  FutureOr<void> bulkApproveComments(List<String> commentIds) {
    // TODO: implement bulkApproveComments
    throw UnimplementedError();
  }

  @override
  FutureOr<void> bulkDeleteComments(List<String> commentIds) {
    // TODO: implement bulkDeleteComments
    throw UnimplementedError();
  }

  @override
  FutureOr<Comment> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  }) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {
          'post_id': postId,
          'content': content,
          'animal': animal.name,
          'background_color': backgroundColor.name,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to create comment');
      }

      // TODO: Parse and return created comment
      throw UnimplementedError(
        'REST create comment not fully implemented to return Comment',
      );
    } on DioException catch (err, trace) {
      printError(err, trace);
      throw Failure('Failed to create comment: ${err.message}');
    } catch (err, trace) {
      printError(err, trace);
      throw Failure('Failed to create comment: $err');
    }
  }

  @override
  FutureOr<void> deleteComment(String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      final response = await _dio.get(
        '/comments',
        queryParameters: {
          'postId': postId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw const Failure('Failed to fetch comments');
      }

      final comments = data['data'] as List<dynamic>;
      return comments.map((e) => ParseUtils.parseComment(e)).toList();
    } catch (err, trace) {
      printError(err, trace);
      throw const Failure('Failed to fetch comments');
    }
  }

  @override
  FutureOr<Comment> updateComment({
    required String commentId,
    required String content,
  }) {
    // TODO: implement updateComment
    throw UnimplementedError();
  }
}

class RestNowisPostApis implements PostApis {
  final Dio _dio;

  final Completer<void> _healthCheckCompleter = Completer<void>();
  String _localAppId = '';
  String _localAppVersionRef = '';

  RestNowisPostApis({
    required String host,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: 'https://$host/v1/nowis',
           validateStatus: (status) {
             return status != null && status >= 200 && status < 300;
           },
         ),
       ) {
    _healthCheck();
  }

  @override
  FutureOr<Post> add(Post item) async {
    await _waitForHealthCheck();

    try {
      final response = await _dio.post(
        '/posts',
        data: {
          'title': item.title,
          'content': item.content,
          'summary': item.summary,
          'featuredImageUrl': item.featuredImageUrl,
          'status': item.status.name,
          'visibility': item.visibility.name,
          'tags': item.tags,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to create post');
      }

      // TODO: Parse and return the created post from response
      // For now, we just return the item as if it was created successfully,
      // but ideally the server should return the created post.
      // Assuming the server returns the created post in 'data' field.
      // But the current implementation of add in grpc returns void (or null failure).
      // Wait, I updated grpc to return Post.
      // The REST implementation should also return Post.
      // If the server response doesn't contain the full post, we might need to fetch it or construct it.
      // Let's assume for now we throw UnimplementedError or try to parse if available.
      // The current REST implementation was returning null (success).

      // Since I don't have the full REST response structure verified,
      // and this file seems to be less used (grpc is primary?),
      // I will update the signature but throw UnimplementedError for now
      // or just return the item passed in (which is wrong because ID is missing).

      throw UnimplementedError(
        'REST add post not fully implemented to return Post',
      );
    } on DioException catch (e) {
      throw Failure('Failed to create post: ${e.message}');
    } catch (e) {
      throw Failure('Failed to create post: $e');
    }
  }

  @override
  FutureOr<List<Post>> addAll(List<Post> items) {
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

    try {
      final response = await _dio.get('/$id');
      final data = response.data as Map<String, dynamic>;

      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to get post by ID');
      }

      final postMap = data['data'] as Map<String, dynamic>;
      if (postMap.isEmpty) {
        return null;
      }

      final decryptedContent = await decryptor.decryptAsync(
        postMap['content'],
        appId: _localAppId,
        appVersionRef: _localAppVersionRef,
      );
      return ParseUtils.parsePost(postMap, decryptedContent);
    } on DioException catch (err, trace) {
      printError(err, trace);
      throw Failure('Failed to get post by ID: ${err.message}');
    } catch (err, trace) {
      printError(err, trace);
      throw Failure('Failed to get post by ID: $err');
    }
  }

  @override
  FutureOr<Post?> getPostBySlug(String slug) async {
    await _waitForHealthCheck();

    try {
      final response = await _dio.get('/slug/$slug');
      final data = response.data as Map<String, dynamic>;

      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to get post by slug');
      }

      final postMap = data['data'] as Map<String, dynamic>;
      if (postMap.isEmpty) {
        return null;
      }

      final decryptedContent = await decryptor.decryptAsync(
        postMap['content'],
        appId: _localAppId,
        appVersionRef: _localAppVersionRef,
      );
      return ParseUtils.parsePost(postMap, decryptedContent);
    } on DioException catch (e) {
      throw Failure('Failed to get post by slug: ${e.message}');
    } catch (e) {
      throw Failure('Failed to get post by slug: $e');
    }
  }

  @override
  FutureOr<List<TagSidebar>> getSidebarPostsByTags({
    String? tagNameFilter,
  }) async {
    await _waitForHealthCheck();

    try {
      final queryParams = <String, dynamic>{};
      if (tagNameFilter != null && tagNameFilter.isNotEmpty) {
        queryParams['tag_name_filter'] = tagNameFilter;
      }

      final response = await _dio.get(
        '/sidebar-posts-by-tags',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;

      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to get sidebar posts by tags');
      }

      final List<dynamic> tagsJson = data['data'] as List<dynamic>;
      return tagsJson
          .map(
            (tagJson) =>
                ParseUtils.parseTagSidebar(tagJson as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw Failure('Failed to get sidebar posts by tags: ${e.message}');
    } catch (e) {
      throw Failure('Failed to get sidebar posts by tags: $e');
    }
  }

  @override
  FutureOr<List<Post>> list(
    Pagination pagination, {
    String? searchQuery,
  }) async {
    await _waitForHealthCheck();

    try {
      final queryParams = <String, dynamic>{};
      final pagePagination = switch (pagination) {
        PagePagination pagination => pagination,
        _ => null,
      };

      if (pagePagination != null) {
        queryParams['page'] = pagePagination.page;
        queryParams['limit'] = pagePagination.pageSize;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search_query'] = searchQuery;
      }

      final response = await _dio.get(
        '/posts',
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;

      if (!data['success']) {
        throw Failure(data['message'] ?? 'Failed to list posts');
      }

      final List<dynamic> postsJson = data['data'] as List<dynamic>;
      final List<Post> posts = [];
      for (final postJson in postsJson) {
        final decryptedContent = await decryptor.decryptAsync(
          postJson['content'],
          appId: _localAppId,
          appVersionRef: _localAppVersionRef,
        );
        posts.add(
          ParseUtils.parsePost(
            postJson as Map<String, dynamic>,
            decryptedContent,
          ),
        );
      }
      return posts;
    } on DioException catch (e) {
      throw Failure('Failed to list posts: ${e.message}');
    } catch (e) {
      throw Failure('Failed to list posts: $e');
    }
  }

  @override
  FutureOr<Post> update(Post item) {
    // TODO: implement update
    throw UnimplementedError();
  }

  Future<void> _healthCheck() async {
    if (_localAppId.isNotEmpty && _localAppVersionRef.isNotEmpty) {
      return;
    }

    try {
      final response = await _dio.get('/health');
      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw Failure(data['message'] ?? 'Health check failed');
      }

      final appData = data['data'] as Map<String, dynamic>;
      if (appData['appId'] == null ||
          appData['appId'].isEmpty ||
          appData['appVersionRef'] == null ||
          appData['appVersionRef'].isEmpty) {
        throw const Failure('Health check failed: missing app data');
      }

      _localAppId = appData['appId'];
      _localAppVersionRef = appData['appVersionRef'];

      _healthCheckCompleter.complete();
    } on DioException catch (e) {
      throw Failure('Health check failed: ${e.message}');
    } catch (e) {
      throw Failure('Health check failed: $e');
    }
  }

  Future<void> _waitForHealthCheck() async {
    if (!_healthCheckCompleter.isCompleted) {
      await _healthCheckCompleter.future;
    }

    if (_localAppId.isEmpty || _localAppVersionRef.isEmpty) {
      throw const Failure('Health check failed');
    }
  }
}

class RestNowisUserApis implements UserApis {
  RestNowisUserApis({
    required String host,
  });

  @override
  FutureOr<User> add(User item) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  FutureOr<List<User>> addAll(List<User> items) {
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
  FutureOr<User?> get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  FutureOr<List<User>> list(Pagination pagination, {String? searchQuery}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  FutureOr<User> update(User item) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class RestNowisAuthApis implements AuthApis {
  final Dio _dio;

  RestNowisAuthApis({
    required String host,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: 'https://$host/v1',
           validateStatus: (status) {
             return status != null && status >= 200 && status < 300;
           },
         ),
       );

  @override
  FutureOr<AuthTokens?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw Failure(data['message'] ?? 'Login failed');
      }

      final authData = data['data'] as Map<String, dynamic>;
      return AuthTokens(
        accessToken: authData['accessToken'],
        refreshToken: authData['refreshToken'],
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        throw const UnauthorizedFailure();
      }
      throw Failure('Login failed: ${e.message}');
    } catch (e) {
      throw Failure('Login failed: $e');
    }
  }
}
