import 'package:flutter/material.dart';
import 'package:hiqradio/src/views/desktop/components/InkClick.dart';
import 'package:hiqradio/src/views/desktop/components/station_info.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int showRecentCount = 5;
  List<String> recent = [];
  @override
  void initState() {
    super.initState();
    recent = List.generate(10, (index) => '搜索: $index').toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Column(
        children: [
          _buildRecent(),
          Expanded(
            child: _buildResult(),
          )
        ],
      ),
    );
  }

  Widget _buildRecent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近搜索',
              style: TextStyle(
                  fontSize: 14.0, color: Colors.grey.withOpacity(0.8)),
            ),
            InkClick(
              child: Text(
                '清空',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red.withOpacity(0.8),
                ),
              ),
              onTap: () {},
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Wrap(
            children: [
              ...recent.map((elem) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkClick(
                    onTap: () {},
                    child: Container(
                      height: 20.0,
                      constraints: const BoxConstraints(maxWidth: 80.0),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        elem,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkClick(
                  onTap: () {},
                  child: Container(
                    height: 20.0,
                    constraints: const BoxConstraints(maxWidth: 80.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Icon(
                      showRecentCount <= 5
                          ? Icons.expand_more_outlined
                          : Icons.expand_less_outlined,
                      size: 16.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Text(
                '搜索结果： 共 ',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.0),
              ),
              Container(
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '7893',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 13.0),
                ),
              ),
              Text(
                ' 个',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.0),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.all(4.0),
                    splashColor: Colors.black.withOpacity(0),
                    title: StationInfo(
                        onClicked: () => {}, width: 200, height: 54),
                    onTap: () => {},
                    mouseCursor: SystemMouseCursors.click,
                  );
                },
                itemCount: 8),
          ),
        )
      ],
    );
  }
}
