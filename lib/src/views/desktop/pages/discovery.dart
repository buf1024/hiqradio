import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/components/station_icon.dart';

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<Discovery> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommend(),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(child: _buildContent())
        ],
      ),
    );
  }

  Widget _buildRecommend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '推荐',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60.0,
                width: 76.0,
                child: ListView.builder(
                  itemCount: 20,
                  padding: const EdgeInsets.all(0),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: StationIcon(),
                    );
                  },
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  

  Widget _buildContent() {
    return Container(
        width: 60,
        child: ListView.builder(
            itemCount: 20,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return StationIcon();
            }));
  }

  @override
  bool get wantKeepAlive => true;
}
