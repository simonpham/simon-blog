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
    _client;
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
  FutureOr<List<Post>> list(Pagination pagination) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  FutureOr<Failure?> update(Post item) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
