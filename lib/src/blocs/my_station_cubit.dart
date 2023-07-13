import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/my_station_state.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyStationCubit extends Cubit<MyStationState> {
  MyStationCubit() : super(const MyStationState());

  Future<Map<String, dynamic>?> _loadLastSearch() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? lastSearch = sp.getString(kSpMSLastSearch);
    if (lastSearch != null) {
      return jsonDecode(lastSearch);
    }
    return null;
  }

  void _saveLastSearch() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {};
    map['search'] = state.searchText;
    map['opt_country'] = state.selectedCountry;
    map['opt_state'] = state.selectedState;
    map['opt_language'] = state.selectedLanguage;
    map['opt_tags'] = state.selectedTags;

    sp.setString(kSpMSLastSearch, jsonEncode(map));
  }

  void initSearch() async {
    if (state.isFirstTrigger) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      int? pageSize = sp.getInt(kSpMSLastPageSize);
      if (pageSize != null) {
        emit(state.copyWith(pageSize: pageSize));
      }

      String searchText = state.searchText;
      String country = state.selectedCountry;
      String countryState = state.selectedState;
      String language = state.selectedLanguage;
      List<String> tags = state.selectedTags;
      Map<String, dynamic>? map = await _loadLastSearch();
      if (map != null) {
        searchText = map['search'];
        country = map['opt_country'];
        countryState = map['opt_state'];
        language = map['opt_language'];
        tags = (map['opt_tags'] as List).map((e) => e as String).toList();

        emit(state.copyWith(
            searchText: searchText,
            selectedCountry: country,
            selectedState: countryState,
            selectedLanguage: language,
            selectedTags: tags));
      }
      await search(state.searchText,
          country: state.selectedCountry,
          countryState: state.selectedState,
          language: state.selectedLanguage,
          tags: state.selectedTags);
      emit(state.copyWith(isFirstTrigger: false));
    }
  }

  Future<List<Station>> search(String name,
      {String country = '',
      String countryState = '',
      String language = '',
      List<String> tags = const []}) async {
    name = name.trim();
    if (!state.isFirstTrigger) {
      if (!state.isConditionChanged && name == state.searchText) {
        return state.stations;
      }
    }
    if (!state.isSearching) {
      _saveLastSearch();

      emit(state.copyWith(
        searchText: name,
        isConditionChanged: false,
        isSearching: true,
        totalSize: 0,
        totalPage: 0,
        page: 0,
      ));

      List<Station> stations = await RadioRepository.instance.search(name,
          country: country,
          countryState: countryState,
          language: language,
          tags: tags);

      int totalSize = stations.length;
      int page = state.page;
      int totalPage = state.totalPage;
      if (state.pageSize > 0) {
        totalPage = totalSize ~/ state.pageSize;
        if (totalSize % state.pageSize > 0) {
          totalPage += 1;
        }
        page = 1;
      }
      emit(state.copyWith(
          stations: stations,
          totalSize: totalSize,
          totalPage: totalPage,
          page: page,
          isSearching: false));

      return stations;
    }
    return state.stations;
  }

  void changePageSize(int pageSize) async {
    if (state.pageSize != pageSize &&
        pageSize > 0 &&
        pageSize <= kMaxPageSize &&
        !state.isSearching) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      sp.setInt(kSpMSLastPageSize, pageSize);

      int totalPage = (state.totalSize / pageSize).truncate();
      if (state.totalSize % pageSize > 0) {
        totalPage += 1;
      }
      int page = 1;
      emit(
          state.copyWith(pageSize: pageSize, totalPage: totalPage, page: page));
    }
  }

  void changePage(int page) {
    if (state.page != page &&
        page > 0 &&
        page <= state.totalPage &&
        !state.isSearching) {
      emit(state.copyWith(page: page));
    }
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
}
