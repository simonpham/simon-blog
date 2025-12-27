import 'package:core/core.dart';
import 'package:core_remote_data/interfaces/post_api.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  PostApis get _postApis => injector.get<PostApis>();

  Future<List<Post>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final posts = await _postApis.list(
        const OffsetLimitPagination(offset: 0, limit: 10),
        searchQuery: query,
      );
      return posts;
    } catch (err, trace) {
      printError(err, trace);
      return [];
    }
  }
}
