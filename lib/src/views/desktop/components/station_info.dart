import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:url_launcher/url_launcher.dart';

class StationInfo extends StatelessWidget {
  final VoidCallback? onClicked;
  final double width;
  final double height;
  const StationInfo(
      {super.key, this.onClicked, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          InkClick(
            onTap: () => onClicked?.call(),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: "https://pic.qtfm.cn/2012/0814/20120814015923282.jpg",
                placeholder: (context, url) {
                  return Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.grey.withOpacity(0.4)
                    ])),
                    child: const Center(
                      child: Icon(
                        IconFont.station,
                        size: 25.0,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.5),
                    ])),
                    child: const Center(
                      child: Icon(
                        IconFont.station,
                        size: 25.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              InkClick(
                onTap: () async {
                  Uri url = Uri.parse('https://flutter.dev');
                  !await launchUrl(url);
                },
                child: Text(
                  '丹东经济广播',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.0, color: Colors.white.withOpacity(0.8)),
                ),
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
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
