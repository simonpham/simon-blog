import 'dart:async';

import 'package:core_remote_data_pb/core_remote_data_pb.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart' as pb;
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

class FakeResponseFuture<T> implements ResponseFuture<T> {
  final Future<T> _future;

  FakeResponseFuture(this._future);

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(T value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<void> cancel() async {}

  @override
  Future<Map<String, String>> get headers => Future.value({});

  @override
  Future<Map<String, String>> get trailers => Future.value({});
}

class MockNowisServiceClient implements pb.NowisServiceClient {
  @override
  ResponseFuture<pb.CreateCommentResponse> createComment(pb.CreateCommentRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.CreatePostResponse> createPost(pb.CreatePostRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetPostCommentsResponse> getPostComments(pb.GetPostCommentsRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetPostByIdResponse> getPostById(pb.GetPostByIdRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetPostBySlugResponse> getPostBySlug(pb.GetPostBySlugRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetPostsResponse> getPosts(pb.GetPostsRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetSidebarPostsByTagsResponse> getSidebarPostsByTags(pb.GetSidebarPostsByTagsRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.GetUserResponse> getUser(pb.GetUserRequest request, {CallOptions? options}) {
    final user = pb.User(
      id: request.id,
      username: 'testuser',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: Int64(1234567890),
      updatedAt: Int64(1234567890),
    );
    return FakeResponseFuture(Future.value(pb.GetUserResponse(user: user)));
  }

  @override
  ResponseFuture<pb.HealthCheckResponse> healthCheck(pb.HealthCheckRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<pb.UpdatePostResponse> updatePost(pb.UpdatePostRequest request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ClientCall<Q, R> $createCall<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseFuture<R> $createUnaryCall<Q, R>(ClientMethod<Q, R> method, Q request, {CallOptions? options}) {
    throw UnimplementedError();
  }

  @override
  ResponseStream<R> $createStreamingCall<Q, R>(ClientMethod<Q, R> method, Stream<Q> requests, {CallOptions? options}) {
    throw UnimplementedError();
  }
}

void main() {
  group('NowisUserApis Unit Test', () {
    test('getUser returns user from client', () async {
      final mockClient = MockNowisServiceClient();
      final api = NowisUserApis(
        host: 'dummy',
        client: mockClient,
      );

      final user = await api.get('user-123');

      expect(user, isNotNull);
      expect(user!.id, 'user-123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
    });
  });
}
