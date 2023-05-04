import 'package:flutter/material.dart';

enum NavType {
  discovery,
  station,
  customized,
  recently,
  record,
  mine
}

enum NavPos { top, bottom }

class NavItem {
  NavType type;
  NavPos pos;
  String label;
  IconData iconData;

  NavItem(
      {required this.type,
      required this.pos,
      required this.label,
      required this.iconData});
}
