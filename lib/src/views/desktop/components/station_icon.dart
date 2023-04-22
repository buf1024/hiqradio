import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';

class StationIcon extends StatelessWidget {
  final VoidCallback? onClicked;
  final VoidCallback? onPlayClicked;

  const StationIcon({super.key, this.onClicked, this.onPlayClicked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      width: 60.0,
      child: Stack(
        children: [
          SizedBox(
            height: 60.0,
            width: 60.0,
            child: InkClick(
              onTap: () => onClicked?.call(),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl:
                      "https://pic.qtfm.cn/2012/0814/20120814015923282.jpg",
                  placeholder: (context, url) {
                    return Image.asset('assets/images/logo.png');
                  },
                  errorWidget: (context, url, error) {
                    return Image.asset('assets/images/logo.png');
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 3.0,
            right: 3.0,
            child: Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.red,
              ),
              child: InkClick(
                onTap: () => onPlayClicked?.call(),
                child: Row(
                  children: [
                    // 不能完全居中
                    const SizedBox(
                      width: 9.0,
                    ),
                    Icon(
                      IconFont.play,
                      size: 10,
                      color: Colors.white.withOpacity(0.9),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
