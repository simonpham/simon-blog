import 'package:ui_file_tree/ui_file_tree.dart';

class FileTreeCategory {
  final String id;
  final String name;

  final List<FileTreeItem> items;

  const FileTreeCategory({
    required this.id,
    required this.name,
    required this.items,
  });
}
