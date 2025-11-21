import 'dart:async';

import 'package:core/core.dart';

abstract interface class CommentApis
    implements _UserCommentApis, _AdminCommentApis {}

abstract interface class _UserCommentApis {
  Future<List<Comment>> getCommentsForPost(String postId);

  FutureOr<Comment> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  });
}

abstract interface class _AdminCommentApis {
  Future<List<Comment>> getCommentsForPost(String postId);

  FutureOr<Comment> createComment({
    required String postId,
    required String content,
    required Animals animal,
    required BackgroundColorType backgroundColor,
  });

  FutureOr<void> deleteComment(String commentId);

  FutureOr<Comment> updateComment({
    required String commentId,
    required String content,
  });

  FutureOr<Comment> approveComment(String commentId);

  FutureOr<void> bulkApproveComments(List<String> commentIds);

  FutureOr<void> bulkDeleteComments(List<String> commentIds);
}
