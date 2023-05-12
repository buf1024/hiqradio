import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/search_state.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  Future<List<String>?> _loadLastSearch() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getStringList(kSpTBLastSearch);
  }

  void _saveLastSearch(String searchText) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {};
    map['search'] = searchText;
    map['opt_country'] = state.selectedCountry;
    map['opt_state'] = state.selectedState;
    map['opt_language'] = state.selectedLanguage;
    map['opt_tags'] = state.selectedTags;
    String s = jsonEncode(map);
    List<String> reSearch = List.from(state.recentSearch);
    int index = reSearch.indexWhere((element) {
      Map<String, dynamic> m = jsonDecode(element);
      return searchText == m['search'];
    });
    if (index < 0) {
      if (reSearch.length < kMaxRecentSearch) {
        reSearch.insert(0, s);
      } else {
        reSearch.removeAt(reSearch.length - 1);
        reSearch.insert(0, s);
      }
    } else {
      reSearch.removeAt(index);
      reSearch.insert(0, s);
    }

    sp.setStringList(kSpTBLastSearch, reSearch);

    emit(state.copyWith(recentSearch: reSearch));
  }

  void initSearch() async {
    List<String>? recentSearch = await _loadLastSearch();
    if (recentSearch != null) {
      emit(state.copyWith(recentSearch: recentSearch));
    }
  }

  Future<List<Station>> search(String name) async {
    name = name.trim();
    if (!state.isConditionChanged && name == state.searchText) {
      return state.stations;
    }

    if (!state.isSearching) {
      if (name.isNotEmpty) {
        _saveLastSearch(name);
      }

      emit(state.copyWith(
        searchText: name,
        isConditionChanged: false,
        isSearching: true,
      ));

      List<Station> stations = await RadioRepository.instance.search(name,
          country: state.selectedCountry,
          countryState: state.selectedState,
          language: state.selectedLanguage,
          tags: state.selectedTags);

      int size =
          stations.length <= kDefListSize ? stations.length : kDefListSize;

      emit(state.copyWith(stations: stations, size: size, isSearching: false));

      return stations;
    }
    return state.stations;
  }

  void selectLanguage(String language) {
    if (state.selectedLanguage != language) {
      emit(
          state.copyWith(selectedLanguage: language, isConditionChanged: true));
    }
  }

  void selectCountry(String country) {
    if (state.selectedCountry != country) {
      emit(state.copyWith(
          selectedCountry: country,
          selectedState: '',
          isConditionChanged: true));
    }
  }

  void selectState(String countryState) {
    if (state.selectedState != countryState) {
      emit(state.copyWith(
          selectedState: countryState, isConditionChanged: true));
    }
  }

  void selectTag(List<String> tags) {
    if (state.selectedTags != tags) {
      emit(state.copyWith(selectedTags: tags, isConditionChanged: true));
    }
  }

  void selectSearchText(String searchText) {
    searchText = searchText.trim();
    if (state.searchText != searchText) {
      emit(state.copyWith(searchText: searchText));
    }
  }

  void changeSearchOption(
      String country, String countryState, String language, List<String> tags) {
    String? newCountry;
    String? newCountryState;
    String? newLanguage;
    List<String>? newTags;
    if (state.selectedCountry != country) {
      newCountry = country;
      newCountryState = '';
    }
    if (state.selectedState != countryState) {
      newCountryState = countryState;
    }
    if (state.selectedLanguage != language) {
      newLanguage = language;
    }
    if (state.selectedTags != tags) {
      newTags = tags;
    }
    if (newCountry != null ||
        newCountryState != null ||
        newLanguage != null ||
        newTags != null) {
      emit(state.copyWith(
          selectedCountry: newCountry,
          selectedState: newCountryState,
          selectedLanguage: newLanguage,
          selectedTags: newTags,
          isConditionChanged: true));
    }
  }

  void searchConditionFromRecently(Map<String, dynamic> map) async {
    var searchText = map['search'];
    var selectedCountry = map['opt_country'];
    var selectedState = map['opt_state'];
    var selectedLanguage = map['opt_language'];
    var selectedTags =
        (map['opt_tags'] as List<dynamic>).map((e) => e as String).toList();

    emit(state.copyWith(
        searchText: searchText,
        selectedCountry: selectedCountry,
        selectedState: selectedState,
        selectedLanguage: selectedLanguage,
        selectedTags: selectedTags,
        isSetSearch: true,
        isConditionChanged: true));

    await search(searchText);
  }

  void resetIsSetSearch(bool isSetSearch) {
    emit(state.copyWith(isSetSearch: isSetSearch));
  }

  void clearRecently() async {
    await RadioRepository.instance.clearRecently();
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setStringList(kSpTBLastSearch, const []);
    emit(state.copyWith(recentSearch: const []));
  }

  void fetchMore() async {
    int size = state.size + kDefListSize;
    if (size > state.stations.length) {
      size = state.stations.length;
    }
    emit(state.copyWith(size: size));
  }
}
