import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/my_station_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/components/station_icon.dart';
import 'package:hiqradio/src/views/components/search_option.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyStation extends StatefulWidget {
  const MyStation({super.key});

  @override
  State<MyStation> createState() => _MyStationState();
}

class _MyStationState extends State<MyStation>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchEditController = TextEditingController();
  FocusNode searchEditFocusNode = FocusNode();
  bool isOptionShow = false;

  TextEditingController pageSizeEditController = TextEditingController();
  FocusNode pageSizeFocusNode = FocusNode();
  bool isPageSizeEditing = false;

  TextEditingController pageEditController = TextEditingController();
  FocusNode pageFocusNode = FocusNode();
  bool isPageEditing = false;

  @override
  void initState() {
    super.initState();

    context.read<MyStationCubit>().initSearch();

    searchEditFocusNode.addListener(() {
      if (!searchEditFocusNode.hasFocus) {
        context.read<AppCubit>().setEditing(false);
      }
    });

    pageSizeFocusNode.addListener(() {
      if (!pageSizeFocusNode.hasFocus) {
        if (isPageSizeEditing) {
          int? pageSize = int.tryParse(pageSizeEditController.text);
          if (pageSize != null) {
            context.read<MyStationCubit>().changePageSize(pageSize);
          }
        }
        setState(() {
          isPageSizeEditing = !isPageSizeEditing;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });
    pageFocusNode.addListener(() {
      if (!pageFocusNode.hasFocus) {
        if (isPageEditing) {
          int? page = int.tryParse(pageEditController.text);
          if (page != null) {
            context.read<MyStationCubit>().changePage(page);
          }
        }

        setState(() {
          isPageEditing = !isPageEditing;
        });
        context.read<AppCubit>().setEditing(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchEditController.dispose();
    searchEditFocusNode.dispose();

    pageSizeEditController.dispose();
    pageSizeFocusNode.dispose();

    pageEditController.dispose();
    pageFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isSearching = context
        .select<MyStationCubit, bool>((value) => value.state.isSearching);

    bool isFirstTrigger = context
        .select<MyStationCubit, bool>((value) => value.state.isFirstTrigger);
    if (isFirstTrigger) {
      String searchText = context
          .select<MyStationCubit, String>((value) => value.state.searchText);

      searchEditController.text = searchText;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(),
          const SizedBox(
            height: 8.0,
          ),
          _buildJumpInfo(),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: !isSearching
                ? _buildContent()
                : Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).textTheme.bodyMedium!.color!,
                        strokeWidth: 2.0),
                  ),
          )
        ],
      ),
    );
  }

  void _onSearch(String value, String country, String countryState,
      String language, List<String> tags) {
    context.read<MyStationCubit>().search(value,
        country: country,
        countryState: countryState,
        language: language,
        tags: tags);
  }

  Widget _buildSearch() {
    String selectedCountry = context
        .select<MyStationCubit, String>((value) => value.state.selectedCountry);
    String selectedState = context
        .select<MyStationCubit, String>((value) => value.state.selectedState);
    String selectedLanguage = context.select<MyStationCubit, String>(
        (value) => value.state.selectedLanguage);
    List<String> selectedTags = context.select<MyStationCubit, List<String>>(
        (value) => value.state.selectedTags);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 250,
              child: _searchField(searchEditController, searchEditFocusNode,
                  (value) {
                _onSearch(searchEditController.text, selectedCountry,
                    selectedState, selectedLanguage, selectedTags);
              }),
            ),
            InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  // '搜索',
                  AppLocalizations.of(context).stat_search,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                _onSearch(searchEditController.text, selectedCountry,
                    selectedState, selectedLanguage, selectedTags);
              },
            ),
            const SizedBox(
              width: 8.0,
            ),
            InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  isOptionShow
                      // ? '隐藏选项'
                      ? AppLocalizations.of(context).stat_hide_option
                      // : '显示选项',
                      : AppLocalizations.of(context).stat_show_option,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  isOptionShow = !isOptionShow;
                });
              },
            )
          ],
        ),
        isOptionShow
            ? SearchOption(
                onOptionChanged: (country, countryState, language, tags) {
                  context.read<MyStationCubit>().changeSearchOption(
                      country, countryState, language, tags);
                },
                selectedCountry: selectedCountry,
                selectedLanguage: selectedLanguage,
                selectedState: selectedState,
                selectedTags: selectedTags,
                titleBarHeight: kTitleBarHeight)
            : Container()
      ],
    );
  }

  Widget _buildJumpInfo() {
    int totalPage =
        context.select<MyStationCubit, int>((value) => value.state.totalPage);

    int totalSize =
        context.select<MyStationCubit, int>((value) => value.state.totalSize);

    int pageSize =
        context.select<MyStationCubit, int>((value) => value.state.pageSize);
    pageSizeEditController.text = '$pageSize';

    int page = context.select<MyStationCubit, int>((value) => value.state.page);
    pageEditController.text = '$page';

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
      child: Row(
        children: [
          const SizedBox(
            width: 6.0,
          ),
          Text(
            // '电台： 共 ',
            AppLocalizations.of(context).stat_station_total,
            style: const TextStyle(fontSize: 13.0),
          ),
          Container(
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '$totalSize',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          Text(
            // ' 个',
            AppLocalizations.of(context).stat_station_unit,
            style: const TextStyle(fontSize: 13.0),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // '每页 ',
              AppLocalizations.of(context).stat_station_per_page,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          _buildEditing(isPageSizeEditing, pageSizeEditController,
              pageSizeFocusNode, '$pageSize', () {
            isPageSizeEditing = true;
            setState(() {});
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // '个 共 ',
              AppLocalizations.of(context).stat_station_total_page,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          Container(
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '$totalPage',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                  fontSize: 13.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // ' 页 当前第 ',
              AppLocalizations.of(context).stat_station_cur_page,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          _buildEditing(
              isPageEditing, pageEditController, pageFocusNode, '$page', () {
            isPageEditing = true;
            setState(() {});
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              // ' 页',
              AppLocalizations.of(context).stat_station_cur_page_no,
              style: const TextStyle(fontSize: 13.0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  // '前一页',
                  AppLocalizations.of(context).stat_station_pre_page,
                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                context.read<MyStationCubit>().changePage(page - 1);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkClick(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  // '后一页',
                  AppLocalizations.of(context).stat_station_next_page,

                  style: const TextStyle(
                    fontSize: 13.0,
                  ),
                ),
              ),
              onTap: () {
                context.read<MyStationCubit>().changePage(page + 1);
              },
            ),
          ),
          const SizedBox(
            width: 6.0,
          )
        ],
      ),
    );
  }

  Widget _buildEditing(bool test, TextEditingController controller,
      FocusNode focusNode, String text, VoidCallback onEditSwitch) {
    return test
        ? SizedBox(
            // padding: const EdgeInsets.symmetric(horizontal: 8.0),
            width: 40.0,
            height: 18.0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              autocorrect: false,
              obscuringCharacter: '*',
              cursorWidth: 1.0,
              showCursor: true,
              cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
              style: const TextStyle(fontSize: 13.0),
              decoration: InputDecoration(
                // hintText: '10~100',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                    borderRadius: BorderRadius.circular(5.0)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              onTap: () {
                context.read<AppCubit>().setEditing(true);
              },
            ),
          )
        : InkClick(
            onTap: () {
              onEditSwitch.call();
              context.read<AppCubit>().setEditing(true);
              pageSizeFocusNode.requestFocus();
            },
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
  }

  Widget _buildContent() {
    List<Station> stations = context.select<MyStationCubit, List<Station>>(
        (value) => value.state.pagedStations);

    Station? playingStation = context
        .select<AppCubit, Station?>((value) => value.state.playingStation);

    bool playingState =
        context.select<AppCubit, bool>((value) => value.state.isPlaying);

    bool bufferingState =
        context.select<AppCubit, bool>((value) => value.state.isBuffering);

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Wrap(
          children: List.generate(stations.length, (index) {
            Station station = stations[index];
            bool isPlaying = playingStation != null &&
                playingStation.urlResolved == station.urlResolved &&
                playingState;
            bool isBuffering = playingStation != null &&
                playingStation.urlResolved == station.urlResolved &&
                bufferingState;

            return Container(
              padding: const EdgeInsets.all(10.0),
              child: StationIcon(
                station: station,
                isPlaying: isPlaying,
                isBuffering: isBuffering,
                onPlayClicked: () {
                  print(
                      'onPlayClicked station: ${station.name} isPlaying: $isPlaying isBuffering: $isBuffering');
                  if (!isPlaying) {
                    context.read<AppCubit>().play(station);
                    context.read<RecentlyCubit>().addRecently(station);
                    if (playingStation != null && playingState) {
                      context
                          .read<RecentlyCubit>()
                          .updateRecently(playingStation);
                    }
                  } else {
                    context.read<AppCubit>().stop();
                    context.read<RecentlyCubit>().updateRecently(station);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _searchField(TextEditingController controller, FocusNode focusNode,
      ValueChanged valueChanged) {
    return Container(
      padding: const EdgeInsets.only(top: 1.0, bottom: 1.0, right: 8.0),
      height: 26.0,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autocorrect: false,
        obscuringCharacter: '*',
        cursorWidth: 1.0,
        cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
        style: const TextStyle(
          fontSize: 12.0,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_outlined,
              size: 18.0,
              color: Theme.of(context).textTheme.bodyMedium!.color!),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.text = '';
                    setState(() {});
                  },
                  child: Icon(Icons.close_outlined,
                      size: 16.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
          fillColor: Colors.grey.withOpacity(0.2),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
            // borderRadius: BorderRadius.circular(50.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
            // borderRadius: BorderRadius.circular(50.0),
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {
          valueChanged.call(value);
        },
        onTap: () {
          context.read<AppCubit>().setEditing(true);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
