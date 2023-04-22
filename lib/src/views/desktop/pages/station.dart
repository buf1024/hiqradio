import 'package:flutter/material.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/components/search_option.dart';
import 'package:hiqradio/src/views/desktop/components/station_icon.dart';

class Station extends StatefulWidget {
  const Station({super.key});

  @override
  State<Station> createState() => _StationState();
}

class _StationState extends State<Station> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SearchOption(), Expanded(child: _buildContent())],
      ),
    );
  }

  
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Wrap(
        children: List.generate(100, (index) {
          return Container(
            padding: EdgeInsets.all(10.0),
            child: StationIcon(),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
