import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/desktop/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/components/station_placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

class StationInfo extends StatelessWidget {
  final VoidCallback? onClicked;
  final double width;
  final double height;
  final Station station;
  const StationInfo(
      {super.key,
      this.onClicked,
      required this.width,
      required this.height,
      required this.station});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Row(
        children: [
          InkClick(
            onTap: () => onClicked?.call(),
            child: SizedBox(
              height: height,
              width: height,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: station.favicon != null
                    ? CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: station.favicon!,
                        placeholder: (context, url) {
                          return const StationPlaceholder(
                            height: 60.0,
                            width: 60.0,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const StationPlaceholder(
                            height: 60.0,
                            width: 60.0,
                          );
                        },
                      )
                    : const StationPlaceholder(
                        height: 60.0,
                        width: 60.0,
                      ),
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
                  if (station.homepage != null) {
                    Uri url = Uri.parse(station.homepage!);
                    await launchUrl(url);
                  }
                },
                child: SizedBox(
                  width: width - height - 8.0,
                  child: Text(
                    station.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.0, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
              SizedBox(
                width: width - height - 8.0,
                child: Text(
                  station.tags != null
                      ? station.tags!.replaceAll(',', '|')
                      : '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.0, color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              SizedBox(
                width: width - height - 8.0,
                child: Text(
                  _getLocationText(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.0, color: Colors.grey.withOpacity(0.8)),
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }

  String _getLocationText() {
    return ResManager.instance
        .getStationInfoText(station.countrycode, station.state, station.language);
  }
}
