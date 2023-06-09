import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/utils/nav.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/phone/pages/my_phone_station.dart';

class PhoneHomePage extends StatefulWidget {
  const PhoneHomePage({super.key});

  @override
  State<PhoneHomePage> createState() => _PhoneHomePageState();
}

class _PhoneHomePageState extends State<PhoneHomePage> {
  final PageController pageController = PageController(keepPage: true);
  late NavItem actNavItem;

  List<NavItem> leftNavTabs = [
    NavItem(
        type: NavType.station,
        pos: NavPos.top,
        // label: '电台',
        iconData: IconFont.station),
    NavItem(
        type: NavType.record,
        pos: NavPos.top,
        // label: '录音',
        iconData: IconFont.record),
  ];

  List<NavItem> rightNavTabs = [
    NavItem(
        type: NavType.discovery,
        pos: NavPos.top,
        // label: '收藏',
        iconData: IconFont.favorite),
    NavItem(
        type: NavType.mine,
        pos: NavPos.top,
        // label: '我的',
        iconData: IconFont.discovery),
  ];

  bool showPlayingStation = true;
  String lastPlayingUrl = '';

  @override
  void initState() {
    super.initState();

    actNavItem = leftNavTabs[0];
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            _playingStation(),
            _buildNavBar()
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return PageView(
        controller: pageController,
        // physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          List<NavItem> tab = leftNavTabs;
          if (index >= 2) {
            tab = rightNavTabs;
            index -= 2;
          }
          setState(() {
            actNavItem = tab[index];
          });
        },
        children: const [
          Center(
            child: MyPhoneStation(),
          ),
          Center(
            child: Text('child 2'),
          ),
          Center(
            child: Text('child 3'),
          ),
          Center(
            child: Text('child 4'),
          ),
        ]);
  }

  void _onNavTabTap(int index, NavItem item) {
    pageController.jumpToPage(index);
    setState(() {
      actNavItem = item;
    });
  }

  Widget _buildNavBar() {
    return Container(
      height: 68,
      decoration: BoxDecoration(color: Theme.of(context).dividerColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...leftNavTabs
              .asMap()
              .entries
              .map((e) => _navTab(e.key, e.value))
              .toList(),
          _playCtrl(),
          ...rightNavTabs
              .asMap()
              .entries
              .map((e) => _navTab(e.key + leftNavTabs.length, e.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _playingStation() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    Size winSize = MediaQuery.of(context).size;

    if (playingStation != null &&
        playingStation.urlResolved != lastPlayingUrl) {
      lastPlayingUrl = playingStation.urlResolved;
      showPlayingStation = true;
    }

    return playingStation != null && showPlayingStation
        ? InkClick(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(color: Theme.of(context).dividerColor),
              child: StationInfo(
                onClicked: () {},
                width: winSize.width - 16,
                height: 54,
                station: playingStation,
              ),
            ),
            onTap: () {
              setState(() {
                showPlayingStation = false;
              });
            },
          )
        : Container();
  }

  Widget _playCtrl() {
    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    return InkClick(
      child: Container(
        width: 50.0,
        height: 50.0,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: const Color(0XFFEA3E3C),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                children: [
                  // 不能完全居中
                  SizedBox(
                    width: !isPlaying ? 13.0 : 10.0,
                  ),
                  Icon(
                    !isPlaying ? IconFont.play : IconFont.stop,
                    size: 20,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            if (isBuffering)
              Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.2),
                    strokeWidth: 2.0,
                  ),
                ),
              )
          ],
        ),
      ),
      onTap: () async {
        if (isPlaying) {
          context.read<AppCubit>().stop();
          if (playingStation != null) {
            context.read<RecentlyCubit>().updateRecently(playingStation);
          }
        } else {
          if (playingStation != null) {
            context.read<AppCubit>().play(playingStation);
            context.read<RecentlyCubit>().addRecently(playingStation);
          }
        }
      },
    );
  }

  Widget _navTab(int index, NavItem elem) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 8.0),
      child: GestureDetector(
        onTap: () {
          _onNavTabTap(index, elem);
        },
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Icon(
                elem.iconData,
                color: actNavItem.type != elem.type
                    ? Theme.of(context).textTheme.bodyMedium!.color!
                    : const Color(0XFFEA3E3C),
                weight: 100,
                size: 18.0,
              ),
              const SizedBox(
                height: 1.0,
              ),
              Text(
                elem.getTypeText(context),                
                style: TextStyle(
                  color: actNavItem.type != elem.type
                      ? Theme.of(context).textTheme.bodyMedium!.color!
                      : const Color(0XFFEA3E3C),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
