import 'dart:async';

import 'package:core/core.dart';

abstract interface class CommentApis
    implements _UserCommentApis, _AdminCommentApis {}

abstract interface class _UserCommentApis {
  Future<List<Comment>> getCommentsForPost(String postId);

  FutureOr<Failure?> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  });
}

abstract interface class _AdminCommentApis {
  Future<List<Comment>> getCommentsForPost(String postId);

  FutureOr<Failure?> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  });

  FutureOr<Failure?> deleteComment(String commentId);

  FutureOr<Failure?> updateComment({
    required String commentId,
    required String content,
  });

  FutureOr<Failure?> approveComment(String commentId);

  FutureOr<Failure?> bulkApproveComments(List<String> commentIds);

  FutureOr<Failure?> bulkDeleteComments(List<String> commentIds);
}
