import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/station_placeholder.dart';

class RotateStation extends StatefulWidget {
  final Station station;
  final ValueChanged<Station>? onClicked;
  const RotateStation({super.key, required this.station, this.onClicked});

  @override
  State<RotateStation> createState() => _RotateStationState();
}

class _RotateStationState extends State<RotateStation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    controller.addListener(() {
      if (controller.status == AnimationStatus.completed) {
        controller.repeat();
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.width - 120.0,
      width: size.width - 120.0,
      margin: const EdgeInsets.only(top: 90.0),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(blurRadius: 1024.0, color: Colors.black.withOpacity(0.5))
      ]),
      child: widget.station.favicon != null &&
              widget.station.favicon!.isNotEmpty
          ? RotationTransition(
              turns: CurvedAnimation(parent: controller, curve: Curves.linear),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(size.width - 120.0)),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: widget.station.favicon!,
                  placeholder: (context, url) {
                    controller.stop();
                    return StationPlaceholder(
                      height: size.width - 120.0,
                      width: size.width - 120.0,
                    );
                  },
                  errorWidget: (context, url, error) {
                    controller.stop();
                    return StationPlaceholder(
                      height: size.width - 120.0,
                      width: size.width - 120.0,
                    );
                  },
                ),
              ),
            )
          : ClipRRect(
              borderRadius:
                  BorderRadius.all(Radius.circular(size.width - 120.0)),
              child: StationPlaceholder(
                height: size.width - 120.0,
                width: size.width - 120.0,
              ),
            ),
    );
  }
}
