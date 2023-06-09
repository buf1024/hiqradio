import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum NavType { discovery, station, customized, recently, record, mine }

enum NavPos { top, bottom }

class NavItem {
  NavType type;
  NavPos pos;
  // String label;
  IconData iconData;

  NavItem(
      {required this.type,
      required this.pos,
      // required this.label,
      required this.iconData});

  String getTypeText(BuildContext context) {
    if (type == NavType.discovery) {
      return AppLocalizations.of(context).mod_discovery;
    } else if (type == NavType.station) {
      return AppLocalizations.of(context).mod_station;
    } else if (type == NavType.customized) {
      return AppLocalizations.of(context).mod_customized;
    } else if (type == NavType.recently) {
      return AppLocalizations.of(context).mod_recently;
    } else if (type == NavType.record) {
      return AppLocalizations.of(context).mod_record;
    } else if (type == NavType.mine) {
      return AppLocalizations.of(context).mod_mine;
    }
    return '';
  }
}
