import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/components/station_icon.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

class MyDiscovery extends StatefulWidget {
  const MyDiscovery({super.key});

  @override
  State<MyDiscovery> createState() => _MyDiscoveryState();
}

class _MyDiscoveryState extends State<MyDiscovery>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double height =
        MediaQuery.of(context).size.height - kTitleBarHeight - kPlayBarHeight;

    return Container(
      height: height,
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecommend(),
            const SizedBox(
              height: 20.0,
            ),
            _buildContent()
          ],
        ),
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
                      child:
                          // todo
                          //  StationIcon(),
                          Text('todo'),
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
    return Column(
      children: [
        _buildCatalogue(),
        _buildMusic(),
        _buildAge(),
      ],
    );
  }

  Widget _buildMusic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '音乐',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        Wrap(
          children: List.generate(10, (index) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child:
                  // todo
                  //  StationIcon(),
                  const Text('todo'),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '年代',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        Wrap(
          children: List.generate(10, (index) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: 
              // todo
                      //  StationIcon(),
                       Text('todo'),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildCatalogue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '类目',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
        ),
        Wrap(
          children: List.generate(10, (index) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: 
              // todo
                      //  StationIcon(),
                       Text('todo'),
            );
          }).toList(),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
