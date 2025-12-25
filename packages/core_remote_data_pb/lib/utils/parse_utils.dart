import 'package:core/core.dart';

class ParseUtils {
  static Post parsePost(Map<String, dynamic> data, String decryptedContent) {
    return Post(
      id: data['id'] as String,
      title: data['title'] as String,
      slug: data['slug'] as String,
      content: decryptedContent,
      summary: data['summary'] as String,
      featuredImageUrl: data['featuredImageUrl'] as String?,
      author: User(
        id: (data['author'] as Map<String, dynamic>)['id'] as String,
        username:
            (data['author'] as Map<String, dynamic>)['username'] as String,
        email: (data['author'] as Map<String, dynamic>)['email'] as String,
        displayName:
            (data['author'] as Map<String, dynamic>)['displayName'] as String,
        avatarUrl:
            (data['author'] as Map<String, dynamic>)['avatarUrl'] as String?,
        avatarHash:
            (data['author'] as Map<String, dynamic>)['avatarHash'] as String?,
        bio: (data['author'] as Map<String, dynamic>)['bio'] as String?,
        createdAt: DateTime.parse(
          (data['author'] as Map<String, dynamic>)['createdAt'] as String,
        ),
        updatedAt: DateTime.parse(
          (data['author'] as Map<String, dynamic>)['updatedAt'] as String,
        ),
      ),
      status: parsePostStatus(data['status'] as String),
      visibility: parsePostVisibility(data['visibility'] as String),
      commentsCount: data['commentsCount'] as int,
      likesCount: data['likesCount'] as int,
      readTimeMinutes: data['readTimeMinutes'] as int,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      tags: List<String>.from(data['tags'] as List<dynamic>),
    );
  }

  static TagSidebar parseTagSidebar(Map<String, dynamic> data) {
    final List<dynamic> postsJson = data['posts'] as List<dynamic>;
    return TagSidebar(
      tagName: data['tag_name'] as String,
      posts:
          postsJson
              .map(
                (postJson) =>
                    parseSidebarPost(postJson as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.slug.compareTo(b.slug)),
    );
  }

  static SidebarPost parseSidebarPost(Map<String, dynamic> data) {
    return SidebarPost(
      id: data['id'] as String,
      title: data['title'] as String,
      slug: data['slug'] as String,
    );
  }

  static PostStatus parsePostStatus(String status) {
    switch (status) {
      case 'draft':
        return PostStatus.draft;
      case 'published':
        return PostStatus.published;
      case 'archived':
        return PostStatus.archived;
      default:
        return PostStatus.draft;
    }
  }

  static PostVisibility parsePostVisibility(String visibility) {
    switch (visibility) {
      case 'public':
        return PostVisibility.public;
      case 'private':
        return PostVisibility.private;
      case 'unlisted':
        return PostVisibility.unlisted;
      default:
        return PostVisibility.private;
    }
  }

  static Comment parseComment(Map<String, dynamic> data) {
    return Comment(
      id: data['id'] as String,
      postId: data['post_id'] as String,
      animal: Animals.fromName(data['animal']),
      backgroundColor: BackgroundColorType.fromString(data['background_color']),
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}
