import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/components/play_ctrl.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/utils/nav.dart';
import 'package:hiqradio/src/views/desktop/components/nav_bar.dart';
import 'package:hiqradio/src/views/desktop/components/play_bar.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/pages/my_favorite.dart';
import 'package:hiqradio/src/views/desktop/pages/my_station.dart';
import 'package:hiqradio/src/views/desktop/pages/my_recently.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController pageController = PageController(keepPage: true);
  late NavItem actNavItem;
  Color navColor = Colors.red;
  double navContentWidth = 120;

  List<NavItem> topNavTabs = [
    NavItem(
        type: NavType.station,
        pos: NavPos.top,
        // label: '电台',
        iconData: IconFont.station),
  ];

  List<NavItem> bottomNavTabs = [
    NavItem(
        type: NavType.recently,
        pos: NavPos.top,
        // label: '最近',
        iconData: IconFont.recently),
    NavItem(
        type: NavType.mine,
        pos: NavPos.top,
        // label: '我的',
        iconData: IconFont.favorite),
  ];

  bool isCompactMode = false;
  Size preWinSize = const Size(900, 400);

  @override
  void initState() {
    super.initState();
    actNavItem = topNavTabs[0];
  }

  @override
  void dispose() {
    super.dispose();

    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: backgroundColor,
      body: Column(
        children: [
          !isCompactMode
              ? Expanded(
                  child: Column(
                    children: [
                      const TitleBar(),
                      Expanded(
                        child: _buildBody(context),
                      ),
                      const PlayBar()
                    ],
                  ),
                )
              : const SizedBox(
                  height: kPlayBarHeight,
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          children: [
                            PlayCtrl(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavBar(
          topNavTabs: topNavTabs,
          bottomNavTabs: bottomNavTabs,
          onTap: (pos, value) => _onNavTabTap(pos, value),
          actType: actNavItem.type,
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(child: _buildNavContent(context))
      ],
    );
  }

  Widget _buildNavContent(BuildContext context) {
    return PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MyStation(),
          // MyCustomized(),
          // MyDiscovery(),
          MyRecently(),
          MyFavorite(),
        ]);
  }

  void _onNavTabTap(NavPos pos, NavItem item) {
    int index = -1;
    if (pos == NavPos.top) {
      index = topNavTabs.indexOf(item);
    } else {
      index = bottomNavTabs.indexOf(item);
      if (index >= 0) {
        index += topNavTabs.length;
      }
    }
    if (index >= 0) {
      pageController.jumpToPage(index);
      setState(() {
        actNavItem = item;
      });
    }
  }
}
