class FileTreeItem {
  final String id;
  final String icon;
  final String name;

  final String? tooltip;

  const FileTreeItem({
    required this.id,
    required this.icon,
    required this.name,
    this.tooltip,
  });
}
