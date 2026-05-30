import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:icons/icons.dart';
import 'package:ui_file_tree/ui_file_tree.dart';

typedef OnFileTreeItemTap = void Function(FileTreeItem item);

class FileTree extends StatefulWidget {
  final List<FileTreeCategory> categories;

  final OnFileTreeItemTap? onItemTap;

  final String? selectedId;

  const FileTree({
    super.key,
    required this.categories,
    this.onItemTap,
    this.selectedId,
  });

  @override
  State<FileTree> createState() => _FileTreeState();
}

class _FileTreeState extends State<FileTree> {
  static const _itemHeight = 24.0;

  final Set<String> _collapsedCategoryIds = {};
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void didUpdateWidget(covariant FileTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    final categoryIds = widget.categories
        .map((category) => category.id)
        .toSet();
    _collapsedCategoryIds.removeWhere((id) => !categoryIds.contains(id));
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _toggleCategory(FileTreeCategory category) {
    setState(() {
      if (!_collapsedCategoryIds.add(category.id)) {
        _collapsedCategoryIds.remove(category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = <_FileTreeRow>[];
    for (final category in widget.categories) {
      rows.add(_FileTreeRow.category(category));
      if (!_collapsedCategoryIds.contains(category.id)) {
        for (final item in category.items) {
          rows.add(_FileTreeRow.item(item));
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = _estimateContentWidth(context).clamp(
          constraints.maxWidth,
          double.infinity,
        );

        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: false,
          notificationPredicate: (notification) => notification.depth == 1,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _verticalController,
              child: SizedBox(
                width: contentWidth,
                height: rows.length * _itemHeight + Spacing.d8,
                child: CustomPaint(
                  painter: _TreeIndentGuidePainter(
                    rows: rows,
                    itemHeight: _itemHeight,
                    topPadding: Spacing.d8,
                    indentSize: Spacing.d20,
                    color: context.theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: Spacing.d8),
                    child: Column(
                      children: [
                        for (final row in rows)
                          SizedBox(
                            height: _itemHeight,
                            child: switch (row) {
                              _CategoryRow(:final category) => _CategoryTreeRow(
                                category: category,
                                isExpanded: !_collapsedCategoryIds.contains(
                                  category.id,
                                ),
                                onTap: () => _toggleCategory(category),
                              ),
                              _ItemRow(:final item) => _PostTreeRow(
                                item: item,
                                isSelected:
                                    widget.selectedId == item.id ||
                                    widget.selectedId == item.name,
                                onTap: () => widget.onItemTap?.call(item),
                              ),
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _estimateContentWidth(BuildContext context) {
    final textStyle = context.theme.textTheme.bodySmall;
    var maxWidth = 240.0;

    for (final category in widget.categories) {
      maxWidth = maxWidth.max(
        _measureText(category.name, textStyle) +
            Spacing.d8 +
            Spacing.d16 +
            Spacing.d4,
      );

      for (final item in category.items) {
        maxWidth = maxWidth.max(
          _measureText(item.name, textStyle) +
              (Spacing.d20 * 1) +
              Spacing.d8 +
              Spacing.d16 +
              Spacing.d4,
        );
      }
    }

    return maxWidth + Spacing.d24;
  }

  double _measureText(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }
}

sealed class _FileTreeRow {
  const _FileTreeRow();

  factory _FileTreeRow.category(FileTreeCategory category) = _CategoryRow;

  factory _FileTreeRow.item(FileTreeItem item) = _ItemRow;
}

class _CategoryRow extends _FileTreeRow {
  final FileTreeCategory category;

  const _CategoryRow(this.category);
}

class _ItemRow extends _FileTreeRow {
  final FileTreeItem item;

  const _ItemRow(this.item);
}

class _CategoryTreeRow extends StatelessWidget {
  final FileTreeCategory category;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CategoryTreeRow({
    required this.category,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Tappable(
      onTap: onTap,
      enableHover: true,
      enableHoverOverlay: false,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: ShapeDecoration(
            color: state.isHovered
                ? colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            shape: SmoothRectangleBorder(
              borderRadius: Spacing.smoothR8,
            ),
          ),
          width: double.infinity,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: Spacing.d8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.chevron_right,
                      size: Spacing.d16,
                      color: colorScheme.onSurface.withValues(alpha: 0.87),
                    ),
                    ImageView(
                      isExpanded ? Assets.folder02 : Assets.folder01,
                      size: Spacing.d16,
                      color: colorScheme.onSurface.withValues(alpha: 0.87),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.d4),
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(
                            alpha: 0.87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostTreeRow extends StatelessWidget {
  final FileTreeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _PostTreeRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Tappable(
      tooltip: item.tooltip,
      onTap: onTap,
      enableHover: true,
      enableHoverOverlay: false,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: ShapeDecoration(
            color: isSelected || state.isHovered
                ? colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            shape: SmoothRectangleBorder(
              borderRadius: Spacing.smoothR8,
            ),
          ),
          width: double.infinity,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: (Spacing.d20 * 1) + Spacing.d8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageView(
                      item.icon,
                      size: Spacing.d16,
                      color: colorScheme.onSurface.withValues(alpha: 0.87),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Spacing.d4),
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: isSelected || state.isHovered
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreeIndentGuidePainter extends CustomPainter {
  final List<_FileTreeRow> rows;
  final double itemHeight;
  final double topPadding;
  final double indentSize;
  final Color color;

  const _TreeIndentGuidePainter({
    required this.rows,
    required this.itemHeight,
    required this.topPadding,
    required this.indentSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (var index = 0; index < rows.length; index++) {
      if (rows[index] is! _CategoryRow) continue;

      var childCount = 0;
      for (var childIndex = index + 1; childIndex < rows.length; childIndex++) {
        if (rows[childIndex] is _CategoryRow) break;
        childCount++;
      }

      if (childCount == 0) continue;

      final x = Spacing.d16;
      final startY = topPadding + ((index + 1) * itemHeight);
      final endY = startY + (childCount * itemHeight);
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreeIndentGuidePainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.itemHeight != itemHeight ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.indentSize != indentSize ||
        oldDelegate.color != color;
  }
}

extension on double {
  double max(double other) => this > other ? this : other;
}
