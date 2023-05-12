import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/station.dart';

class SearchState extends Equatable {
  final List<Station> stations;
  final int size;

  final String searchText;
  final bool isConditionChanged;
  final bool isSetSearch;

  final bool isSearching;

  final List<String> selectedTags;
  final String selectedLanguage;
  final String selectedCountry;
  final String selectedState;

  final List<String> recentSearch;

  const SearchState(
      {this.stations = const [],
      this.searchText = '',
      this.isSetSearch = false,
      this.isConditionChanged = false,
      this.isSearching = false,
      this.size = 0,
      this.selectedTags = const [],
      this.selectedLanguage = '',
      this.selectedCountry = '',
      this.selectedState = '',
      this.recentSearch = const []});

  SearchState copyWith(
      {List<Station>? stations,
      String? searchText,
      bool? isSetSearch,
      bool? isConditionChanged,
      bool? isSearching,
      int? size,
      List<String>? selectedTags,
      String? selectedLanguage,
      String? selectedCountry,
      String? selectedState,
      List<String>? recentSearch}) {
    return SearchState(
      stations: stations ?? this.stations,
      searchText: searchText ?? this.searchText,
      isSetSearch: isSetSearch ?? this.isSetSearch,
      isConditionChanged: isConditionChanged ?? this.isConditionChanged,
      isSearching: isSearching ?? this.isSearching,
      size: size ?? this.size,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedState: selectedState ?? this.selectedState,
      recentSearch: recentSearch ?? this.recentSearch,
    );
  }

  @override
  List<Object?> get props => [
        stations,
        searchText,
        isSetSearch,
        isConditionChanged,
        isSearching,
        size,
        selectedTags,
        selectedLanguage,
        selectedCountry,
        selectedState,
        recentSearch
      ];
}
