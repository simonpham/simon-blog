import 'dart:async';

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
  FutureOr<Failure?> add(Post item) {
    // TODO: implement addAll
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
  FutureOr<Failure?> update(Post item) {
    // TODO: implement update
    throw UnimplementedError();
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
