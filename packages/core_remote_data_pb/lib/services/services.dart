import 'dart:async';

import 'package:core/models/common/failure.dart';
import 'package:core/models/common/pagination.dart';
import 'package:core/models/post.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart' as pb;
import 'package:grpc/grpc.dart';

class NowisPostApis implements PostApis {
  final pb.NowisServiceClient _client;

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
       );

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
  FutureOr<Post?> get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  FutureOr<List<Post>> list(Pagination pagination) async {
    final pagePagination = switch (pagination) {
      PagePagination pagination => pagination,
      _ => null,
    };
    final response = await _client.getPosts(
      pb.GetPostsRequest(
        limit: pagePagination?.pageSize,
        page: pagePagination?.page,
      ),
    );
    return response.posts
        .map(
          (post) => Post(
            id: post.id,
            title: post.title,
            slug: post.slug,
            content: post.content,
            summary: post.summary,
            authorId: post.authorId,
            tags: post.tags.toList(),
            featuredImageUrl: post.featuredImageUrl,
            status: switch (post.status) {
              pb.PostStatus.draft => PostStatus.draft,
              pb.PostStatus.published => PostStatus.published,
              pb.PostStatus.archived => PostStatus.archived,
              _ => PostStatus.draft,
            },
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              post.createdAt.toInt(),
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              post.updatedAt.toInt(),
            ),
            commentsCount: post.commentsCount,
            likesCount: post.likesCount,
            readTimeMinutes: post.readTimeMinutes,
            visibility: switch (post.visibility) {
              pb.PostVisibility.public => PostVisibility.public,
              pb.PostVisibility.private => PostVisibility.private,
              pb.PostVisibility.unlisted => PostVisibility.unlisted,
              _ => PostVisibility.public,
            },
          ),
        )
        .toList();
  }

  @override
  FutureOr<Failure?> update(Post item) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
