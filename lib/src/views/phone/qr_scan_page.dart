import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key? key}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                  controller: controller,
                  errorBuilder: (context, error, child) {
                    return Container();
                  },
                  onDetect: (barcode) {
                    if (barcode.barcodes.first.rawValue != null) {
                      Navigator.of(context)
                          .pop(barcode.barcodes.first.rawValue!);
                    }
                  }),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: kToolbarHeight,
                      padding: const EdgeInsets.only(left: 15.0, top: 40),
                      child: InkClick(
                          child: const Icon(
                            Icons.arrow_back,
                            size: 22,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  height: 60,
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: controller.hasTorchState,
                        builder: (context, state, child) {
                          if (state != true) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            color: Colors.white,
                            icon: ValueListenableBuilder(
                              valueListenable: controller.torchState,
                              builder: (context, state, child) {
                                switch (state) {
                                  case TorchState.off:
                                    return const Icon(
                                      Icons.flash_off,
                                      color: Colors.grey,
                                    );
                                  case TorchState.on:
                                    return const Icon(
                                      Icons.flash_on,
                                      color: Colors.yellow,
                                    );
                                }
                              },
                            ),
                            iconSize: 32.0,
                            onPressed: () => controller.toggleTorch(),
                          );
                        },
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.image),
                        iconSize: 32.0,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            await controller.analyzeImage(image.path);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
