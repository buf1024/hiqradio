import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/views/desktop/utils/nav.dart';


class NavBar extends StatefulWidget {
  final List<NavItem>? topNavTabs;
  final List<NavItem>? bottomNavTabs;
  final NavType actType;
  final void Function(NavPos, NavItem)? onTap;
  const NavBar(
      {super.key,
      this.topNavTabs,
      this.bottomNavTabs,
      required this.actType,
      this.onTap});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late NavType actType;

  Set<NavType> mouseInSet = {};

  @override
  void initState() {
    super.initState();
    actType = widget.actType;
  }

  @override
  void didUpdateWidget(covariant NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actType != widget.actType) {
      actType = widget.actType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kNaviBarWidth,
      child: Column(
        children: [
          ..._buildWidget(NavPos.top, widget.topNavTabs),
          const Spacer(),
          ..._buildWidget(NavPos.bottom, widget.bottomNavTabs),
        ],
      ),
    );
  }

  BoxDecoration? _boxDecoration(NavType type) {
    if (actType == type || mouseInSet.contains(type)) {
      return BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5.0));
    }
    return null;
  }

  List<Widget> _buildWidget(NavPos pos, List<NavItem>? navTabs) {
    if (navTabs == null) {
      return [];
    }
    return navTabs.map((elem) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: MouseRegion(
          onEnter: (event) {
            setState(() {
              mouseInSet.add(elem.type);
            });
          },
          onExit: (event) {
            setState(() {
              mouseInSet.remove(elem.type);
            });
          },
          child: GestureDetector(
            onTap: (() {
              setState(() {
                actType = elem.type;
              });
              widget.onTap?.call(pos, elem);
            }),
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: _boxDecoration(elem.type),
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Icon(
                    elem.iconData,
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    weight: 100,
                    size: 18.0,
                  ),
                  const SizedBox(
                    height: 1.0,
                  ),
                  Text(
                    elem.label,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
