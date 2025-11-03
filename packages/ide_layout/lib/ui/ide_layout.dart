import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:ide_layout/ui/ui.dart';
import 'package:multi_split_view/multi_split_view.dart';

class IdeLayout extends StatelessWidget {
  final WidgetBuilder topBar;
  final WidgetBuilder bottomBar;
  final WidgetBuilder leftPanel;
  final WidgetBuilder rightPanel;
  final WidgetBuilder bottomPanel;
  final WidgetBuilder content;

  const IdeLayout({
    super.key,
    required this.topBar,
    required this.bottomBar,
    required this.leftPanel,
    required this.rightPanel,
    required this.bottomPanel,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    const dividerThickness = 2.0;
    final dividerColor = context.theme.dividerColor.withValues(
      alpha: 0.25,
    );
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
              initialAreas: <Area>[
                Area(
                  id: LeftPanel.id,
                  size: LeftPanel.defaultWidth,
                  min: LeftPanel.minWidth,
                  max: LeftPanel.maxWidth,
                  builder: (context, area) => LeftPanel(leftPanel),
                ),
                Area(
                  builder: (context, area) => MultiSplitView(
                    axis: Axis.vertical,
                    initialAreas: [
                      Area(
                        builder: (context, area) => MainContent(content),
                      ),
                      Area(
                        id: BottomPanel.id,
                        min: BottomPanel.minHeight,
                        max: BottomPanel.maxHeight,
                        size: BottomPanel.minHeight,
                        builder: (context, area) => BottomPanel(bottomPanel),
                      ),
                    ],
                  ),
                ),
                Area(
                  id: RightPanel.id,
                  size: RightPanel.defaultWidth,
                  min: RightPanel.defaultWidth,
                  max: RightPanel.maxWidth,
                  builder: (context, area) => RightPanel(rightPanel),
                ),
              ],
            ),
          ),
          divider,
          BottomBar(bottomPanel),
        ],
      ),
    );
  }
}
