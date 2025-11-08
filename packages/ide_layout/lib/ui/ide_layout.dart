import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:multi_split_view/multi_split_view.dart';

class IdeLayout extends StatelessWidget {
  final IdeLayoutController controller;

  final WidgetBuilder topBar;
  final WidgetBuilder bottomBar;

  const IdeLayout({
    super.key,
    required this.controller,
    required this.topBar,
    required this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return _IdeLayout(
      controller: controller.outerController,
      topBar: topBar,
      bottomBar: bottomBar,
    );
  }
}

class _IdeLayout extends StatelessWidget {
  final MultiSplitViewController controller;

  final WidgetBuilder topBar;
  final WidgetBuilder bottomBar;

  const _IdeLayout({
    required this.controller,
    required this.topBar,
    required this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    const dividerThickness = 1.0;
    final dividerColor = context.theme.dividerColor;
    final divider = Container(
      color: dividerColor,
      height: dividerThickness,
      width: double.infinity,
    );
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: dividerThickness,
        dividerPainter: DividerPainter(
          backgroundColor: dividerColor,
        ),
      ),
      child: Column(
        children: [
          TopBar(topBar),
          divider,
          Expanded(
            child: MultiSplitView(
              controller: controller,
              initialAreas: controller.areas,
            ),
          ),
          divider,
          BottomBar(bottomBar),
        ],
      ),
    );
  }
}
