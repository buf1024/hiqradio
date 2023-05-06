import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/res_manager.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
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
                          return _placeHolder();
                        },
                        errorWidget: (context, url, error) {
                          return _placeHolder();
                        },
                      )
                    : _placeHolder(),
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
                    !await launchUrl(url);
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
    String flag = '';
    if (station.countrycode != null) {
      Map<String, CountryInfo> map = ResManager.instance.countryMap;
      CountryInfo? countryInfo = map[station.countrycode];
      if (countryInfo != null) {
        flag = countryInfo.flag;
      }
    }
    String language = station.language ?? '';
    if (language.isNotEmpty) {
      Map<String, String> map = ResManager.instance.nativeLangMap;
      language = language.toLowerCase();
      if (map.containsKey(language)) {
        language = map[language]!;
      }
    }

    String countryState = station.state ?? '';

    return '$flag $language $countryState';
  }

  Widget _placeHolder() {
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
  }
}
