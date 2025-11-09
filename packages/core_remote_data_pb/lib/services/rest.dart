import 'dart:async';

import 'package:core/core.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/utils/decryptor.dart' as decryptor;
import 'package:core_remote_data_pb/utils/parse_utils.dart';
import 'package:dio/dio.dart';

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
  FutureOr<Failure?> add(Post item) {
    // TODO: implement add
    throw UnimplementedError();
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
  FutureOr<Failure?> update(Post item) {
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
