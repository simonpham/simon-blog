extension SidebarPostExtension on SidebarPost {
  String get fileName => '$slug.md';
}

class SidebarPost {
  final String id;
  final String title;
  final String slug;

  const SidebarPost({
    required this.id,
    required this.title,
    required this.slug,
  });
}

class TagSidebar {
  final String tagName;
  final List<SidebarPost> posts;

  const TagSidebar({
    required this.tagName,
    required this.posts,
  });
}
