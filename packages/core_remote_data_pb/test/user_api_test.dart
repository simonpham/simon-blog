import 'package:core/models/models.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart';
import 'package:test/test.dart';

void main() {
  final PostApis nowisPostApis = NowisPostApis(
    host: 'api.nowis.sofluffy.io',
  );

  final UserApis nowisUserApis = NowisUserApis(
    host: 'api.nowis.sofluffy.io',
  );

  group('NowisUserApis', () {
    String authorId = '';

    test('get user by id from post author', () async {
      // First get a post to find a valid author ID
      final posts = await nowisPostApis.list(
        PagePagination.initial(),
      );

      expect(posts, isNotEmpty);
      authorId = posts.first.author.id;
      expect(authorId, isNotEmpty);

      // Now get the user
      final user = await nowisUserApis.get(authorId);

      expect(user, isNotNull);
      expect(user!.id, authorId);
      expect(user.username, isNotEmpty);
    });
  });
}
