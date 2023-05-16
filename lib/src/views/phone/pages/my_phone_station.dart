import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/my_station_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/blocs/search_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_info.dart';
import 'package:hiqradio/src/views/components/search_option.dart';
import 'package:hiqradio/src/views/phone/playing_page.dart';

class MyPhoneStation extends StatefulWidget {
  const MyPhoneStation({super.key});

  @override
  State<MyPhoneStation> createState() => _MyPhoneStationState();
}

class _MyPhoneStationState extends State<MyPhoneStation>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditFocusNode = FocusNode();

  bool isOptionShow = false;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initSearch();

    searchEditFocusNode.addListener(() {
      if (!searchEditFocusNode.hasFocus) {
        context.read<AppCubit>().setEditing(false);
      }
    });
  }

  void initSearch() async {
    context.read<SearchCubit>().initSearch();
    String? text = await context.read<SearchCubit>().recentSearch();
    if (text != null) {
      setState(() {
        searchEditController.text = text;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchEditController.dispose();
    searchEditFocusNode.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String selectedCountry = context
        .select<MyStationCubit, String>((value) => value.state.selectedCountry);
    String selectedState = context
        .select<MyStationCubit, String>((value) => value.state.selectedState);
    String selectedLanguage = context.select<MyStationCubit, String>(
        (value) => value.state.selectedLanguage);
    List<String> selectedTags = context.select<MyStationCubit, List<String>>(
        (value) => value.state.selectedTags);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      child: Column(
        children: [
          Container(
            child: _searchTextField(),
          ),
          if (isOptionShow)
            SearchOption(
                onOptionChanged: (country, countryState, language, tags) {
                  context.read<MyStationCubit>().changeSearchOption(
                      country, countryState, language, tags);
                },
                selectedCountry: selectedCountry,
                selectedLanguage: selectedLanguage,
                selectedState: selectedState,
                selectedTags: selectedTags,
                titleBarHeight: 0),
          Expanded(child: _buildResult())
        ],
      ),
    );
  }

  Widget _buildResult() {
    int totalSize = context
        .select<SearchCubit, int>((value) => value.state.stations.length);
    bool isSearching =
        context.select<SearchCubit, bool>((value) => value.state.isSearching);

    int size = context.select<SearchCubit, int>((value) => value.state.size);

    List<Station> stations = context
        .select<SearchCubit, List<Station>>((value) => value.state.stations);

    bool isPlaying =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool isBuffering =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    Size winSize = MediaQuery.of(context).size;
    return Column(
      children: [
        isSearching
            ? Container(
                padding: const EdgeInsets.only(top: 45.0),
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              )
            : Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Station station = stations[index];
                      bool isStationPlaying = isPlaying &&
                          playingStation!.urlResolved == station.urlResolved;
                      return Container(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            InkClick(
                              child: StationInfo(
                                onClicked: () {},
                                width: winSize.width - 68,
                                height: 55,
                                station: station,
                              ),
                              onTap: () {
                                // if (isPlaying) {
                                //   context.read<AppCubit>().stop();
                                //   if (playingStation != null) {
                                //     context
                                //         .read<RecentlyCubit>()
                                //         .updateRecently(playingStation);
                                //   }
                                // } else {
                                //   context.read<AppCubit>().play(station);
                                //   context
                                //       .read<RecentlyCubit>()
                                //       .addRecently(station);
                                // }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PlayingPage(),
                                  ),
                                );
                              },
                            ),
                            InkClick(
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!,
                                  ),
                                  borderRadius: BorderRadius.circular(40.0),
                                  // color: Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Row(
                                        children: [
                                          // 不能完全居中
                                          SizedBox(
                                            width:
                                                !isStationPlaying ? 8.0 : 5.0,
                                          ),
                                          Icon(
                                            !isStationPlaying
                                                ? IconFont.play
                                                : IconFont.stop,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                    if (isBuffering && isStationPlaying)
                                      Center(
                                        child: SizedBox(
                                          height: 40.0,
                                          width: 40.0,
                                          child: CircularProgressIndicator(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                if (isPlaying) {
                                  context.read<AppCubit>().stop();
                                  if (playingStation != null) {
                                    context
                                        .read<RecentlyCubit>()
                                        .updateRecently(playingStation);
                                    if (playingStation.urlResolved !=
                                        station.urlResolved) {
                                      context.read<AppCubit>().play(station);
                                      context
                                          .read<RecentlyCubit>()
                                          .addRecently(station);
                                    }
                                  }
                                } else {
                                  context.read<AppCubit>().play(station);
                                  context
                                      .read<RecentlyCubit>()
                                      .addRecently(station);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: size >= totalSize ? size : size + 1,
                    controller: scrollController,
                  ),
                ),
              )
      ],
    );
  }

  Widget _searchTextField() {
    bool isSetSearch =
        context.select<SearchCubit, bool>((value) => value.state.isSetSearch);
    String searchText =
        context.select<SearchCubit, String>((value) => value.state.searchText);
    if (isSetSearch) {
      searchEditController.text = searchText;
      context.read<SearchCubit>().resetIsSetSearch(false);
    }

    Color dividerColor = Theme.of(context).dividerColor;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 1.0, bottom: 1.0, left: 4.0),
            height: 40.0,
            child: TextField(
              controller: searchEditController,
              focusNode: searchEditFocusNode,
              autocorrect: false,
              obscuringCharacter: '*',
              cursorWidth: 1.0,
              showCursor: true,
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
              style: const TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: '电台搜索',
                prefixIcon: Icon(Icons.search_outlined,
                    size: 18.0, color: Colors.grey.withOpacity(0.8)),
                suffixIcon: searchEditController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchEditController.text = '';
                          setState(() {});
                        },
                        child: Icon(Icons.close_outlined,
                            size: 15.0, color: Colors.grey.withOpacity(0.8)),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0),
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (value) {
                setState(() {});
                context.read<SearchCubit>().search(value);
              },
              onTap: () {
                context.read<AppCubit>().setEditing(true);
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 4.0),
          height: 40.0,
          width: 52.0,
          decoration: BoxDecoration(
              color: dividerColor,
              border: Border.all(
                color: dividerColor,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              )),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isOptionShow = !isOptionShow;
              });
            },
            child: Icon(Icons.filter_alt_outlined,
                size: 15.0,
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
