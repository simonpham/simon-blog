import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/comment_api.dart';
import 'package:flutter/material.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentApis _apis = injector<CommentApis>();

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Post? _post;

  void setPost(Post? post) {
    final currentPostId = _post?.id;
    final newPostId = post?.id;
    if (currentPostId == newPostId) {
      return;
    }
    _post = post;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final postId = _post?.id;
    if (postId == null) {
      _comments = [];
      notifyListeners();
      return;
    }

    try {
      final fetchedComments = await _apis.getCommentsForPost(postId);
      _comments = fetchedComments;
    } catch (err, trace) {
      // TODO: Handle error.
      printError(err, trace);
      _comments = [];
    }
    notifyListeners();
  }

  Future<Failure?> createComment(String text) async {
    // TODO: Implement comment creation logic.
    return null;
  }
}
