import 'package:flutter/material.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StationQrCode extends StatefulWidget {
  final Station station;
  final double width;
  final double height;
  final VoidCallback? onTap;
  const StationQrCode(
      {super.key,
      required this.station,
      required this.width,
      required this.height,
      this.onTap});

  @override
  State<StationQrCode> createState() => _StationQrCodeState();
}

class _StationQrCodeState extends State<StationQrCode> {
  GlobalKey pngKey = GlobalKey();
  bool isSaving = false;
  _StationQrCodeState();

  @override
  Widget build(BuildContext context) {
    const padding = 12.0;
    var qrWidth = widget.width - padding * 2;
    var qrLogoWidth = qrWidth * 0.25;

    // var generatedColor = Random().nextInt(Colors.primaries.length);
    // var color = Colors.primaries[generatedColor];

    return RepaintBoundary(
      key: pngKey,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            // color: color,
            color: Color(0xff8e4b18),
          ),
          child: Column(
            children: [
              StationInfo(
                onClicked: () {},
                width: qrWidth,
                height: 60,
                station: widget.station,
              ),
              const SizedBox(
                height: 25.0,
              ),
              SizedBox(
                height: qrWidth,
                width: qrWidth,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: QrImageView(
                    data: widget.station.stationuuid,
                    version: QrVersions.auto,
                    size: qrWidth,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    embeddedImage: const AssetImage('assets/images/logo.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(qrLogoWidth, qrLogoWidth),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Text(
                AppLocalizations.of(context)!.cmm_scan_to_play,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .color!
                      .withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Container(
                alignment: Alignment.centerRight,
                height: 28,
                child: InkClick(
                  child: Text(
                    AppLocalizations.of(context)!.cmm_save_picture,
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  onTap: () async {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
