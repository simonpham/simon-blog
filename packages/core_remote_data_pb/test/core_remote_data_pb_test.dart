import 'package:core/models/models.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart'
    show NowisPostApis, NowisCommentApis, RestNowisAuthApis;
import 'package:test/test.dart';

void main() {
  final PostApis nowisPostApis = NowisPostApis(
    host: 'api.nowis.sofluffy.io',
  );

  final CommentApis nowisCommentApis = NowisCommentApis(
    host: 'api.nowis.sofluffy.io',
  );

  final AuthApis nowisAuthApis = RestNowisAuthApis(
    host: 'api.nowis.sofluffy.io',
  );

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

    test('create comment', () async {
      final result = await nowisCommentApis.createComment(
        postId: firstPostId,
        content: 'test comment',
        animal: Animals.cat,
        backgroundColor: BackgroundColorType.orange,
      );
      expect(result, isA<Comment>());
    });

    test('get comments for post', () async {
      final result = await nowisCommentApis.getCommentsForPost(firstPostId);
      expect(result, isA<List<Comment>>());
    });

    String accessToken = '';
    test('login', () async {
      final result = await nowisAuthApis.login(
        username: 'test@sofluffy.io',
        password: 'password123',
      );
      expect(result, isA<AuthTokens>());
      expect(result!.accessToken, isNotEmpty);
      expect(result.refreshToken, isNotEmpty);
      accessToken = result.accessToken;
    });

    String createdPostId = '';

    test('addPost', () async {
      if (nowisPostApis is NowisPostApis) {
        nowisPostApis.setAccessToken(accessToken);
      }
      final result = await nowisPostApis.add(
        Post.newPost(
          title: 'test post',
          content: 'test content',
          tags: ['test-tag'],
          summary: '',
          author: User(
            id: 'test-user',
            username: 'testuser',
            email: 'test@example.com',
            displayName: 'Test User',
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
          visibility: PostVisibility.public,
          status: PostStatus.published,
        ),
      );
      expect(result, isA<Post>());
      createdPostId = result.id;
    });

    test('updatePost', () async {
      if (nowisPostApis is NowisPostApis) {
        nowisPostApis.setAccessToken(accessToken);
      }

      expect(createdPostId, isNotEmpty);
      final postToUpdate = await nowisPostApis.get(createdPostId);
      expect(postToUpdate, isNotNull);

      final updatedPost = postToUpdate!.copyWith(
        title: 'updated test post',
        content: 'updated test content',
      );

      final result = await nowisPostApis.update(updatedPost);
      expect(result, isA<Post>());
      expect(result.title, 'updated test post');

      // Verify update
      final fetchedPost = await nowisPostApis.get(postToUpdate.id);
      expect(fetchedPost, isNotNull);
      expect(fetchedPost!.title, 'updated test post');
    });
  });
}
