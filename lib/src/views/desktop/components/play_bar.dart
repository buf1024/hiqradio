import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:hiqradio/src/views/desktop/utils/nav.dart';
import 'package:flutter/services.dart' show rootBundle;

class PlayBar extends StatefulWidget {
  final void Function(NavType type) onStatusTap;
  const PlayBar({super.key, required this.onStatusTap});

  @override
  State<PlayBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<PlayBar> {
  @override
  Widget build(BuildContext context) {
    Color dividerColor = Theme.of(context).dividerColor;

    return SizedBox(
      height: kPlayBarHeight,
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: dividerColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStationInfo(),
                    _buildFuncs(),
                  ],
                ),
                Center(
                  child: _buildPlayControl(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStationInfo() {
    return SizedBox(
      width: 200.0,
      height: 54.0,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.grey.withOpacity(0.8),
      //   ),
      // ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: "https://pic.qtfm.cn/2012/0814/20120814015923282.jpg",
              placeholder: (context, url) {
                return Image.asset('assets/images/logo.png');
              },
              errorWidget: (context, url, error) {
                return Image.asset('assets/images/logo.png');
              },
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '丹东经济广播',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.0, color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                'traffic|交通|娱乐|音乐',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.0, color: Colors.grey.withOpacity(0.8)),
              ),
              Text(
                '🇨🇳 中文 广东',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.0, color: Colors.grey.withOpacity(0.8)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayControl() {
    return Container(
      width: 280.0,
      height: 54.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey.withOpacity(0.8)),
      // ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.timer, size: 20.0),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Icon(
                IconFont.favoriteFill,
                size: 20.0,
                color: Colors.red.withOpacity(0.8),
              ),
              onTap: () {},
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: Icon(IconFont.previous,
                  size: 20.0, color: Colors.red.withOpacity(0.8)),
              onTap: () {},
            ),
          ),
          InkClick(
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.red.withOpacity(0.8),
              ),
              child: Row(
                children: const [
                  // 不能完全居中
                  SizedBox(
                    width: 18.0,
                  ),
                  Icon(
                    IconFont.play,
                    size: 20,
                  )
                ],
              ),
            ),
            onTap: () async {
              String codes =
                  await rootBundle.loadString('assets/files/emoji-flags.json');
              List<dynamic> js = jsonDecode(codes);
              var map = HashMap<String, String>();
              js.forEach((element) {
                Map<String, dynamic> jt = element as Map<String, dynamic>;
                var c = jt['code'];
                var emoji = jt['emoji'];
                if (!map.containsKey(c)) {
                  map[c] = emoji;
                }
              });
              print('CN=${map["CN"]}');
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkClick(
              child: Icon(IconFont.next,
                  size: 20.0, color: Colors.red.withOpacity(0.8)),
              onTap: () {},
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.record, size: 20.0),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: const Icon(IconFont.share, size: 20.0),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuncs() {
    return SizedBox(
      height: 54.0,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkClick(
            child: const Icon(IconFont.random, size: 20.0),
            onTap: () {},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkClick(
            child: const Icon(IconFont.volume, size: 20.0),
            onTap: () {},
          ),
        ),
      ]),
    );
  }
}
