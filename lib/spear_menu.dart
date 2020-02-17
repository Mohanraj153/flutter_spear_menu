library spear_menu;

import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'triangle_painter.dart';

abstract class MenuItemProvider {
  String get menuTitle;

  bool get activeStatus;
  actStatus(bool value);

  TextStyle get menuTextStyle;
}

class MenuItem extends MenuItemProvider {
  String title; // Menu title
  TextStyle textStyle;
  bool isActive;

  MenuItem({this.title, this.textStyle, this.isActive});

  @override
  String get menuTitle => title;

  @override
  bool get activeStatus => isActive ?? false;

  @override
//  TextStyle get menuTextStyle => textStyle ?? TextStyle(color: Color(0xffc5c5c5), fontSize: 14.0);
  TextStyle get menuTextStyle => textStyle ?? TextStyle(color: Colors.black87, fontSize: 14.0);

  @override
  actStatus(bool value) {
    // TODO: implement actStatus
    isActive = value;
  }

}

typedef MenuClickCallback = Function(MenuItemProvider item);
typedef SpearMenuStateChanged = Function(bool isShow);

class SpearMenu {
//  static var itemWidth = 152.0;
  static var itemWidth = MediaQuery.of(context).size.width * 0.50;
  static var itemHeight = 60.0;
  static var arrowHeight = 10.0;
  OverlayEntry _entry;
  List<MenuItemProvider> items;

  /// row count
  int _row;

  /// The left top point of this menu.
  Offset _offset;

  /// Menu will show at above or under this rect
  Rect _showRect;

  /// if false menu is show above of the widget, otherwise menu is show under the widget
  bool _isDown = true;

  /// callback
  VoidCallback dismissCallback;
  MenuClickCallback onClickMenu;
  SpearMenuStateChanged stateChanged;

  Size _screenSize; // Screen size

  /// Cannot be null
  static BuildContext context;

  /// style
  Color _backgroundColor;
  Color _highlightColor;
  Color _lineColor;

  /// It's showing or not.
  bool _isShow = false;

  bool get isShow => _isShow;

  SpearMenu(
      {MenuClickCallback onClickMenu,
        BuildContext context,
        VoidCallback onDismiss,
        Color backgroundColor,
        Color highlightColor,
        Color lineColor,
        SpearMenuStateChanged stateChanged,
        List<MenuItemProvider> items}) {
    this.onClickMenu = onClickMenu;
    this.dismissCallback = onDismiss;
    this.stateChanged = stateChanged;
    this.items = items;
    this._backgroundColor = backgroundColor ?? Colors.white;
    this._lineColor = lineColor ?? Colors.grey;
    this._highlightColor = highlightColor ?? Colors.grey;
    if (context != null) {
      SpearMenu.context = context;
    }
  }

  void show({Rect rect, GlobalKey widgetKey, List<MenuItemProvider> items}) {
    if (rect == null && widgetKey == null) {
      print("'rect' and 'key' can't be both null");
      return;
    }

    this.items = items ?? this.items;
    this._showRect = rect ?? SpearMenu.getWidgetGlobalRect(widgetKey);
    this._screenSize = window.physicalSize / window.devicePixelRatio;
    this.dismissCallback = dismissCallback;

    _calculatePosition(SpearMenu.context);

    _entry = OverlayEntry(builder: (context) {
      return buildSpearMenuLayout(_offset);
    });

    Overlay.of(SpearMenu.context).insert(_entry);
    _isShow = true;
    if (this.stateChanged != null) {
      this.stateChanged(true);
    }
  }

  static Rect getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  void _calculatePosition(BuildContext context) {
    _row = items.length;
    _offset = _calculateOffset(SpearMenu.context);
  }

  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect.left + _showRect.width / 2.0 - menuWidth() / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + menuWidth() > _screenSize.width && dx > 10.0) {
      double tempDx = _screenSize.width - menuWidth() - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect.top - menuHeight();
    if (dy <= MediaQuery.of(context).padding.top + 10) {
      // The have not enough space above, show menu under the widget.
      dy = arrowHeight + _showRect.height + _showRect.top;
      _isDown = false;
    } else {
      dy -= arrowHeight;
      _isDown = true;
    }

    return Offset(dx, dy);
  }

  double menuWidth() {
    return itemWidth;
  }

  // This height exclude the arrow
  double menuHeight() {
    return itemHeight * _row;
  }

  LayoutBuilder buildSpearMenuLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          dismiss();
        },
        onVerticalDragStart: (DragStartDetails details) {
          dismiss();
        },
        onHorizontalDragStart: (DragStartDetails details) {
          dismiss();
        },
        child: Container(
          decoration: new BoxDecoration(
              border: new Border.all(width: 2.0, color: Colors.transparent), color: Colors.black.withOpacity(0.5)),
          child: Stack(
            children: <Widget>[
              // triangle arrow
              Positioned(
                left: _showRect.left + _showRect.width / 2.0 - 7.5,
                top: _isDown ? offset.dy + menuHeight() : offset.dy - arrowHeight,
                child: CustomPaint(
                  size: Size(15.0, arrowHeight),
                  painter: TrianglePainter(isDown: _isDown, color: _backgroundColor),
                ),
              ),
              // menu content
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Container(
                  width: menuWidth(),
                  height: menuHeight(),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: menuWidth(),
                            height: menuHeight(),
                            decoration:
                            BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              children: _createRows(),
                            ),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  // Create line
  List<Widget> _createRows() {
    List<Widget> rows = [];
    for (int i = 0; i < _row; i++) {
      Color color = (i < _row - 1 && _row != 1) ? _lineColor : Colors.transparent;
      Widget rowWidget = Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 0.5))),
        height: itemHeight,
        child: Row(
          children: _createRowItems(i),
        ),
      );

      rows.add(rowWidget);
    }

    return rows;
  }

  //Create a line of item,  row Count from 0
  List<Widget> _createRowItems(int row) {
    List<MenuItemProvider> subItems = items.sublist(row, min(row + 1, items.length));
    List<Widget> itemWidgets = [];
    for (var item in subItems) {
      itemWidgets.add(_createMenuItem(item));
    }

    return itemWidgets;
  }

  Widget _createMenuItem(MenuItemProvider item) {
    return _MenuItemWidget(
      item: item,
      clickCallback: itemClicked,
      backgroundColor: _backgroundColor,
      highlightColor: _highlightColor,
    );
  }

  void itemClicked(MenuItemProvider item) {
    if (onClickMenu != null) {
      onClickMenu(item);
    }

    dismiss();
  }

  void dismiss() {
    if (!_isShow) {
      // Remove method should only be called once
      return;
    }

    _entry.remove();
    _isShow = false;
    if (dismissCallback != null) {
      dismissCallback();
    }

    if (this.stateChanged != null) {
      this.stateChanged(false);
    }
  }
}

class _MenuItemWidget extends StatefulWidget {
  final MenuItemProvider item;

//  final Color lineColor;
  final Color backgroundColor;
  final Color highlightColor;

  final Function(MenuItemProvider item) clickCallback;

  _MenuItemWidget({this.item, this.clickCallback, this.backgroundColor, this.highlightColor});

  @override
  _MenuItemWidgetState createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<_MenuItemWidget> {
  var highlightColor = Color(0x55000000);
  var color = Color(0xff232323);

  @override
  void initState() {
    color = widget.backgroundColor;
    highlightColor = widget.highlightColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        color = highlightColor;
        setState(() {});
      },
      onTapUp: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onLongPressEnd: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onTap: () {
        if (widget.clickCallback != null) {
          widget.clickCallback(widget.item);
        }
      },
      child: Container(
          width: SpearMenu.itemWidth,
          height: SpearMenu.itemHeight,
          decoration: BoxDecoration(
            color: color,
          ),
          child: _createContent()),
    );
  }

  Widget _createContent() {
    bool activeMode = widget.item.activeStatus;
    return Container(
      padding: EdgeInsets.all(12.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Material(
              color: Colors.transparent,
              child: Text(widget.item.menuTitle, style: widget.item.menuTextStyle.copyWith(fontWeight: activeMode ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
          Visibility(
            visible: activeMode,
            child: Icon(
              Icons.check,
              color: Colors.lightGreen,
            ),
          )
        ],
      ),
    );
  }
}

