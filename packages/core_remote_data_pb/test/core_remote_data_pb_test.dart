import 'package:core/models/models.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart'
    show NowisPostApis;
import 'package:test/test.dart';

void main() {
  final PostApis nowisPostApis = NowisPostApis(
    host: 'api.nowis.sofluffy.io',
  );

  setUpAll(() async {
    if (nowisPostApis is NowisPostApis) {
      await nowisPostApis.healthCheck();
    }
  });

  group('NowisPostApis', () {
    String firstPostId = '';
    String firstPostSlug = '';

    test('get list ', () async {
      final result = await nowisPostApis.list(
        PagePagination.initial(),
      );

      expect(result, isA<List<Post>>());
      expect(result.length, greaterThan(0));

      firstPostId = result.first.id;
      firstPostSlug = result.first.slug;
    });

    test('get post by id', () async {
      final result = await nowisPostApis.get(firstPostId);
      expect(result, isA<Post>());
      expect(result!.id, firstPostId);
    });

    test('get post by slug', () async {
      final result = await nowisPostApis.getPostBySlug(firstPostSlug);
      expect(result, isA<Post>());
      expect(result!.slug, firstPostSlug);
    });

    test('get sidebar posts by tags', () async {
      final result = await nowisPostApis.getSidebarPostsByTags();
      expect(result, isA<List<TagSidebar>>());
      expect(result.length, greaterThan(0));
    });

    test('search posts', () async {
      const searchQuery = 'flutter';
      final result = await nowisPostApis.list(
        const PagePagination(
          page: 1,
          pageSize: 10,
        ),
        searchQuery: searchQuery,
      );

      expect(result, isA<List<Post>>());
      expect(result.length, greaterThan(0));
    });

    test('search posts - empty', () async {
      const searchQuery = 'dummy';
      final result = await nowisPostApis.list(
        const PagePagination(
          page: 1,
          pageSize: 10,
        ),
        searchQuery: searchQuery,
      );

      expect(result, isA<List<Post>>());
      expect(result.length, 0);
    });
  });
}
