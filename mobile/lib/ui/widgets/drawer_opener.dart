import 'package:flutter/material.dart';

/// Inherited widget that exposes the root Scaffold's GlobalKey so
/// nested screens can call openDrawer() without needing a BuildContext
/// that is a direct child of that Scaffold.
class DrawerOpener extends InheritedWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrawerOpener({
    super.key,
    required this.scaffoldKey,
    required super.child,
  });

  static DrawerOpener? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrawerOpener>();
  }

  static void open(BuildContext context) {
    DrawerOpener.of(context)?.scaffoldKey.currentState?.openDrawer();
  }

  @override
  bool updateShouldNotify(DrawerOpener oldWidget) => false;
}
