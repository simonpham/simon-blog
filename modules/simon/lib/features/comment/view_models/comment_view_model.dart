import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/comment_api.dart';
import 'package:flutter/material.dart';
import 'package:simon/simon.dart';

class CommentViewModel extends ChangeNotifier {
  CommentApis get _apis => injector<CommentApis>();

  AnonymousUser get anonymousUser => SettingsBox().anonymousUser;

  Animals get animal => anonymousUser.animal;
  BackgroundColorType get backgroundColor => anonymousUser.backgroundColor;

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
    fetchComments();
  }

  Future<void> fetchComments() async {
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
    final postId = _post?.id;
    if (postId == null) {
      return const Failure('No post selected');
    }

    try {
      await _apis.createComment(
        postId: postId,
        content: text,
        animal: animal,
        backgroundColor: backgroundColor,
      );
      return null;
    } on Failure catch (failure) {
      return failure;
    } catch (err, trace) {
      // TODO: Handle error.
      printError(err, trace);
      return const Failure('Failed to create comment');
    }
  }
}
