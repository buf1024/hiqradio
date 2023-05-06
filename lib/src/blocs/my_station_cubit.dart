import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/my_station_state.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/res_manager.dart';

class MyStationCubit extends Cubit<MyStationState> {
  MyStationCubit() : super(const MyStationState());

  String lastSearch() {
    return state.searchText;
  }

  void initSearch() async {
    if (state.isFirstTrigger) {
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
    if (!state.isFirstTrigger) {
      if (name == state.searchText &&
          country == state.selectedCountry &&
          countryState == state.selectedState &&
          language == state.selectedLanguage &&
          tags == state.selectedTags) {
        return state.stations;
      }
    }
    if (!state.isSearching) {
      emit(state.copyWith(
        searchText: name,
        isSearching: true,
        totalSize: 0,
        totalPage: 0,
        page: 0,
      ));
      if (country.isNotEmpty) {
        Map<String, CountryInfo> map = ResManager.instance.countryMap;
        CountryInfo? countryInfo = map[country];
        if (countryInfo != null) {
          country = countryInfo.name;
        }
      }
      List<String> cnStates = [];
      if (countryState.isNotEmpty && country == 'China') {
        Map<String, List<String>> map = ResManager.instance.cnL2RMap;
        List<String>? stateInfo = map[countryState];
        if (stateInfo != null) {
          cnStates.addAll(stateInfo);
        }
      }
      if (language.isNotEmpty) {
        Map<String, LanguageInfo> map = ResManager.instance.langMap;
        LanguageInfo? languageInfo = map[language];
        if (languageInfo != null) {
          language = languageInfo.name.toLowerCase();
        }
      }
      print(
          'search: $name, country: $country, countryState: $countryState, language: $language, tags: ${tags.join(',')}');
      RadioApi api = await RadioApi.create();
      List<Station> stations = [];

      List<dynamic> stationsList = [];
      if (cnStates.isEmpty) {
        stationsList = await api.search(
            name: name,
            country: country.isEmpty ? null : country,
            state: countryState.isEmpty ? null : countryState,
            language: language.isEmpty ? null : language,
            tagList: tags.isEmpty ? null : tags.join(','),
            hidebroken: true);
      } else {
        for (var cnState in cnStates) {
          List<dynamic> list = await api.search(
              name: name,
              country: country.isEmpty ? null : country,
              state: cnState,
              language: language.isEmpty ? null : language,
              tagList: tags.isEmpty ? null : tags.join(','),
              hidebroken: true);
          stationsList.addAll(list);
        }
      }

      Set<String> cache = {};

      for (var station in stationsList) {
        if (station['name'] == null ||
            (station['name'] as String).isEmpty ||
            station['url_resolved'] == null ||
            (station['url_resolved'] as String).isEmpty) {
          continue;
        }
        Station sStation = Station.fromJson(station);

        if (sStation.countrycode != null &&
            sStation.countrycode!.toUpperCase() == 'TW') {
          continue;
        }
        if (!cache.contains(sStation.urlResolved)) {
          if (((sStation.countrycode != null &&
                      sStation.countrycode!.toUpperCase() == 'CN') ||
                  (sStation.country != null &&
                      sStation.country!.toUpperCase() == 'CHINA')) &&
              (sStation.state != null && sStation.state!.isNotEmpty)) {
            Map<String, String> map = ResManager.instance.cnR2LMap;
            String? countryState = map[sStation.state];
            sStation = sStation.copyWith(state: countryState ?? '');
          }

          stations.add(sStation);

          cache.add(sStation.urlResolved);
        }
      }
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
      print('stations: ${stations.length}');
      return stations;
    }
    return state.stations;
  }

  void changePageSize(int pageSize) {
    if (state.pageSize != pageSize &&
        pageSize > 0 &&
        pageSize < kMaxPageSize &&
        !state.isSearching) {
      int totalPage = (state.totalSize / pageSize).truncate();
      if (state.totalSize ~/ pageSize > 0) {
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
      emit(state.copyWith(selectedLanguage: language));
    }
  }

  void selectCountry(String country) {
    if (state.selectedCountry != country) {
      emit(state.copyWith(selectedCountry: country, selectedState: ''));
    }
  }

  void selectState(String countryState) {
    if (state.selectedState != countryState) {
      emit(state.copyWith(selectedState: countryState));
    }
  }

  void selectTag(List<String> tags) {
    if (state.selectedTags != tags) {
      emit(state.copyWith(selectedTags: tags));
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
          selectedTags: newTags));
    }
  }
}
