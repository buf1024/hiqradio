import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/utils/nav.dart';
import 'package:hiqradio/src/views/desktop/components/nav_bar.dart';
import 'package:hiqradio/src/views/desktop/components/play_bar.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/lock_page.dart';
import 'package:hiqradio/src/views/desktop/pages/config.dart';
import 'package:hiqradio/src/views/desktop/pages/discovery.dart';
import 'package:hiqradio/src/views/desktop/pages/favorite.dart';
import 'package:hiqradio/src/views/desktop/pages/station.dart';
import 'package:hiqradio/src/views/desktop/pages/recently.dart';
import 'package:hiqradio/src/views/desktop/pages/record.dart';
import 'package:window_manager/window_manager.dart';

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
        type: NavType.discovery,
        pos: NavPos.top,
        label: '发现',
        iconData: IconFont.discovery),
    NavItem(
        type: NavType.station,
        pos: NavPos.top,
        label: '电台',
        iconData: IconFont.station),
  ];

  List<NavItem> bottomNavTabs = [
    NavItem(
        type: NavType.recently,
        pos: NavPos.top,
        label: '最近',
        iconData: IconFont.recently),
    NavItem(
        type: NavType.record,
        pos: NavPos.top,
        label: '录音',
        iconData: IconFont.record),
    NavItem(
        type: NavType.mine,
        pos: NavPos.top,
        label: '我的',
        iconData: IconFont.favorite),
  ];

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
          TitleBar(
            // child: const Text('HiqRadio'),
            onSearchChanged: (value) {},
            onSearchClicked: () {},
            onCompactClicked: () => onLockScreen(),
            onConfigClicked: () async {
              Size size = await windowManager.getSize();
              // onShowConfigDialog(size.width - 80.0, size.height - 80.0);
              onShowConfigDialog(400.0, size.height - 32);
            },
          ),
          Expanded(
            child: _buildBody(context),
          ),
          PlayBar(
            onStatusTap: (type) => onStatusTap(type),
          )
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
          Discovery(),
          Station(),
          Recently(),
          Record(),
          Favorite(),
        ]);
    // return NavContent(
    //   onContentResizeCallback: (width) {},
    //   leftChild: PageView(
    //     controller: pageController,
    //     physics: const NeverScrollableScrollPhysics(),
    //     children: const [
    //       Discovery(),
    //       Local(),
    //       International(),
    //       Recently(),
    //       Record(),
    //       Favorite(),
    //     ],
    //   ),
    //   rightChild: const Text('right content'),
    // );
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

  void onStatusTap(NavType type) async {
    int index = topNavTabs.indexWhere((item) => item.type == type);
    if (index >= 0) {
      pageController.jumpToPage(index);
      setState(() {
        actNavItem = topNavTabs[index];
      });
    } else {
      // if (type == NavType.notification) {
      //   Size size = await windowManager.getSize();
      //   onShowNotificationDialog(size.width - 80.0, size.height - 80.0);
      // }
    }
  }

  void onLockScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LockPage(),
      ),
    );
  }

  void onShowNotificationDialog(double width, double height) {
    onShowConfigDialog(width, height);
  }

  void onShowConfigDialog(double width, double height) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.0),
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.centerRight,
          insetPadding:
              const EdgeInsets.only(top: 32.0, bottom: 0, right: 0, left: 0),
          // backgroundColor: Colors.blue.withOpacity(0.8),
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: <Widget>[
                Container(
                  height: 32.0,
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '系统参数配置',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Expanded(child: ConfigView()),
                ButtonBar(
                  children: <Widget>[
                    MaterialButton(
                      color: Colors.purple,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
