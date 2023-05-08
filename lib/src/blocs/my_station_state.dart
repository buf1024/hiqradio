import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/constant.dart';

class MyStationState extends Equatable {
  final bool isFirstTrigger;

  final List<Station> stations;

  final String searchText;
  final bool isConditionChanged;

  final bool isSearching;
  

  final int totalSize;
  final int pageSize;
  final int totalPage;
  final int page;

  final List<String> selectedTags;
  final String selectedLanguage;
  final String selectedCountry;
  final String selectedState;

  const MyStationState({
    this.isFirstTrigger = true,
    this.stations = const [],
    this.searchText = kDefSearchText,
    this.isConditionChanged = false,
    this.isSearching = false,
    this.totalSize = 0,
    this.pageSize = kDefPageSize,
    this.totalPage = 0,
    this.page = 0,
    this.selectedTags = const [],
    this.selectedLanguage = '',
    this.selectedCountry = '',
    this.selectedState = '',
  });

  MyStationState copyWith({
    bool? isFirstTrigger,
    List<Station>? stations,
    String? searchText,
    bool? isConditionChanged,
    bool? isSearching,
    int? totalSize,
    int? pageSize,
    int? totalPage,
    int? page,
    List<String>? selectedTags,
    String? selectedLanguage,
    String? selectedCountry,
    String? selectedState,
  }) {
    return MyStationState(
      isFirstTrigger: isFirstTrigger ?? this.isFirstTrigger,
      stations: stations ?? this.stations,
      searchText: searchText ?? this.searchText,
      isConditionChanged: isConditionChanged ?? this.isConditionChanged,
      isSearching: isSearching ?? this.isSearching,
      totalSize: totalSize ?? this.totalSize,
      pageSize: pageSize ?? this.pageSize,
      totalPage: totalPage ?? this.totalPage,
      page: page ?? this.page,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedState: selectedState ?? this.selectedState,
    );
  }

  get pagedStations {
    if (stations.isNotEmpty) {
      int start = (page - 1) * pageSize;
      int end = start + pageSize;
      if (end > stations.length) {
        end = stations.length;
      }
      if (start <= end) {
        return stations.getRange(start, end).toList();
      }
    }
    return const <Station>[];
  }

  @override
  List<Object?> get props => [
        isFirstTrigger,
        stations,
        searchText,
        isConditionChanged,
        isSearching,
        totalSize,
        pageSize,
        totalPage,
        page,
        selectedTags,
        selectedLanguage,
        selectedCountry,
        selectedState,
      ];
}
