import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/components/play_ctrl.dart';
import 'package:hiqradio/src/views/desktop/components/search.dart';
import 'package:hiqradio/src/views/desktop/pages/customized.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/views/desktop/utils/nav.dart';
import 'package:hiqradio/src/views/desktop/components/nav_bar.dart';
import 'package:hiqradio/src/views/desktop/components/play_bar.dart';
import 'package:hiqradio/src/views/desktop/components/title_bar.dart';
import 'package:hiqradio/src/views/desktop/components/config.dart';
import 'package:hiqradio/src/views/desktop/pages/discovery.dart';
import 'package:hiqradio/src/views/desktop/pages/favorite.dart';
import 'package:hiqradio/src/views/desktop/pages/my_station.dart';
import 'package:hiqradio/src/views/desktop/pages/recently.dart';
import 'package:hiqradio/src/views/desktop/pages/record.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
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
        type: NavType.station,
        pos: NavPos.top,
        label: '电台',
        iconData: IconFont.station),
    NavItem(
        type: NavType.customized,
        pos: NavPos.top,
        label: '自定',
        iconData: IconFont.customized),
    NavItem(
        type: NavType.discovery,
        pos: NavPos.top,
        label: '发现',
        iconData: IconFont.discovery),
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

  bool isCompactMode = false;
  Size preWinSize = const Size(900, 400);

  @override
  void initState() {
    super.initState();
    _registerHotKey();

    actNavItem = topNavTabs[0];
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void _registerHotKey() async {
    HotKey hotKey = HotKey(
      KeyCode.space,
      // 设置热键范围（默认为 HotKeyScope.system）
      scope: HotKeyScope.inapp, // 设置为应用范围的热键。
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        context.read<AppCubit>().pauseResume();
      },
      // 只在 macOS 上工作。
      // keyUpHandler: (hotKey) {
      //   print('onKeyUp+${hotKey.toJson()}');
      // },
    );
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
                      TitleBar(
                        onSearchChanged: (value) {},
                        onSearchClicked: () async {},
                        onCompactClicked: () async {
                          Size size = await windowManager.getSize();
                          preWinSize = size;

                          await windowManager.setTitleBarStyle(
                              TitleBarStyle.hidden,
                              windowButtonVisibility: false);
                          setState(() {
                            isCompactMode = !isCompactMode;
                          });
                          await windowManager
                              .setSize(const Size(314.0, kPlayBarHeight));
                          await windowManager.setResizable(false);
                        },
                        onConfigClicked: () async {
                          Size size = await windowManager.getSize();
                          _onShowDlg(
                              300.0,
                              size.height - kTitleBarHeight - kPlayBarHeight,
                              const Config());
                        },
                      ),
                      Expanded(
                        child: _buildBody(context),
                      ),
                      const PlayBar()
                    ],
                  ),
                )
              : SizedBox(
                  height: kPlayBarHeight,
                  child: Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          windowManager.startDragging();
                        },
                      ),
                      Center(
                        child: Row(
                          children: [
                            const PlayCtrl(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkClick(
                                child: const Icon(IconFont.quit, size: 20.0),
                                onTap: () async {
                                  await windowManager.setTitleBarStyle(
                                      TitleBarStyle.hidden,
                                      windowButtonVisibility: true);
                                  await windowManager.setSize(preWinSize);

                                  setState(() {
                                    isCompactMode = !isCompactMode;
                                  });
                                },
                              ),
                            )
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
          Customized(),
          Discovery(),
          Recently(),
          Record(),
          Favorite(),
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

  void _onShowDlg(double width, double height, Widget child) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.0),
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.centerRight,
          insetPadding: const EdgeInsets.only(
              top: kTitleBarHeight, bottom: kPlayBarHeight, right: 0, left: 0),
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
            ),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: <Widget>[
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
