import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/utils.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
                AppLocalizations.of(context).cmm_scan_to_play,
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
                  child:  Text(
                    AppLocalizations.of(context).cmm_save_picture,
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  onTap: () async {
                    if (!isSaving) {
                      isSaving = true;
                      await _saveImage();
                      isSaving = false;
                      widget.onTap?.call();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    RenderRepaintBoundary? boundary =
        pngKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;

    if (boundary != null) {
      var image = await boundary.toImage(pixelRatio: 5.0);
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      String toastMsg = '图片已保存';
      if (isDesktop()) {
        var directory = await getDownloadsDirectory();
        var p = join(directory!.path, '${widget.station.name}.png');
        toastMsg = '$toastMsg : $p';
        var file = File(p);
        file.writeAsBytes(pngBytes);
      } else {
        await ImageGallerySaver.saveImage(pngBytes, name: widget.station.name);
        toastMsg = '$toastMsg : Storage/Pictures/${widget.station.name}.png';
      }
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }
}
