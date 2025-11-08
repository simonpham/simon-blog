import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:ide_layout/ide_layout.dart';
import 'package:multi_split_view/multi_split_view.dart';

enum IdePanel {
  leftPanel(0),
  rightPanel(2),
  bottomPanel(1);

  final int areaIndex;

  const IdePanel(this.areaIndex);

  String get id => toString();
}

typedef IdePanelStateChanged = void Function(IdePanel panel, bool isExpanded);

class IdeLayoutController {
  final IdePanelStateChanged? onPanelStateChanged;

  /// Left Pandel, Inner, Right Panel.
  final MultiSplitViewController outerController;

  /// Main Content, Bottom Panel.
  final MultiSplitViewController innerController;

  const IdeLayoutController({
    required this.outerController,
    required this.innerController,
    this.onPanelStateChanged,
  });

  factory IdeLayoutController.create({
    required final WidgetBuilder leftPanel,
    required final WidgetBuilder rightPanel,
    required final WidgetBuilder bottomPanel,
    required final WidgetBuilder content,
    IdePanelStateChanged? onPanelStateChanged,
  }) {
    final innerController = MultiSplitViewController(
      areas: [
        Area(
          builder: (context, area) => MainContent(content),
        ),
        Area(
          id: IdePanel.bottomPanel.id,
          min: BottomPanel.minHeight,
          max: BottomPanel.maxHeight,
          size: BottomPanel.minHeight,
          builder: (context, area) => BottomPanel(bottomPanel),
        ),
      ],
    );
    return IdeLayoutController(
      onPanelStateChanged: onPanelStateChanged,
      outerController: MultiSplitViewController(
        areas: [
          Area(
            id: IdePanel.leftPanel.id,
            size: LeftPanel.defaultWidth,
            min: LeftPanel.minWidth,
            max: LeftPanel.maxWidth,
            builder: (context, area) => LeftPanel(leftPanel),
          ),
          Area(
            builder: (context, area) => MultiSplitView(
              controller: innerController,
              axis: Axis.vertical,
              initialAreas: innerController.areas,
            ),
          ),
          Area(
            id: IdePanel.rightPanel.id,
            size: RightPanel.defaultWidth,
            min: RightPanel.minWidth,
            max: RightPanel.maxWidth,
            builder: (context, area) => RightPanel(rightPanel),
          ),
        ],
      ),
      innerController: innerController,
    );
  }

  void hide(IdePanel section) {
    switch (section) {
      case IdePanel.leftPanel:
        outerController.getArea(IdePanel.leftPanel.areaIndex).size =
            LeftPanel.minWidth;
        onPanelStateChanged?.call(section, false);
        break;
      case IdePanel.rightPanel:
        outerController.getArea(IdePanel.rightPanel.areaIndex).size =
            RightPanel.minWidth;
        onPanelStateChanged?.call(section, false);
        break;
      case IdePanel.bottomPanel:
        innerController.getArea(IdePanel.bottomPanel.areaIndex).size =
            BottomPanel.minHeight;
        onPanelStateChanged?.call(section, false);
        break;
    }
  }

  void show(IdePanel section) {
    switch (section) {
      case IdePanel.leftPanel:
        outerController.getArea(IdePanel.leftPanel.areaIndex).size =
            LeftPanel.defaultWidth;
        onPanelStateChanged?.call(section, true);
        break;
      case IdePanel.rightPanel:
        outerController.getArea(IdePanel.rightPanel.areaIndex).size =
            RightPanel.defaultWidth;
        onPanelStateChanged?.call(section, true);
        break;
      case IdePanel.bottomPanel:
        innerController.getArea(IdePanel.bottomPanel.areaIndex).size =
            BottomPanel.defaultHeight;
        onPanelStateChanged?.call(section, true);
        break;
    }
  }

  bool isVisible(IdePanel section) {
    switch (section) {
      case IdePanel.leftPanel:
        final size = outerController.getArea(IdePanel.leftPanel.areaIndex).size;
        return size != null && size > LeftPanel.minWidth;
      case IdePanel.rightPanel:
        final size = outerController
            .getArea(IdePanel.rightPanel.areaIndex)
            .size;
        return size != null && size > RightPanel.minWidth;
      case IdePanel.bottomPanel:
        final size = innerController
            .getArea(IdePanel.bottomPanel.areaIndex)
            .size;
        return size != null && size > BottomPanel.minHeight;
    }
  }

  void toggle(IdePanel section) {
    if (isVisible(section)) {
      hide(section);
      return;
    }
    show(section);
  }

  void handleWindowSizedChanged(Size size) {
    if (size.height < BottomPanel.minHeight) {
      hide(IdePanel.bottomPanel);
    } else {
      show(IdePanel.bottomPanel);
    }

    if (size.width < 800) {
      hide(IdePanel.leftPanel);
    } else {
      show(IdePanel.leftPanel);
    }

    if (size.width < 600) {
      hide(IdePanel.rightPanel);
    } else {
      show(IdePanel.rightPanel);
    }
  }
}
