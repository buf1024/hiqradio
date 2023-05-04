import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/search_opt_state.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/repository/radioapi/radioapi.dart';
import 'package:hiqradio/src/utils/res_manager.dart';

class SearchOptCubit extends Cubit<SearchOptState> {
  SearchOptCubit() : super(const SearchOptState());

  Future<List<Language>> loadLanguage() async {
    if (state.languages.isEmpty) {
      emit(state.copyWith(isLangLoading: true));

      RadioApi api = await RadioApi.create();
      List<Language> languages = [];
      var languageList = await api.languages();
      for (var language in languageList) {
        if (language['name'] == null ||
            (language['name'] as String).isEmpty ||
            language['iso_639'] == null ||
            (language['iso_639'] as String).length > 2) {
          continue;
        }
        String langCode = (language['iso_639'] as String).toLowerCase();
        Map<String, LanguageInfo> map = ResManager.instance.langMap;
        if (map.containsKey(langCode)) {
          languages.add(Language.fromJson(language));
        }
      }
      emit(state.copyWith(languages: languages, isLangLoading: false));
      return languages;
    }
    return state.languages;
  }

  void selectLanguage(String language) {
    if (state.selectedLanguage != language) {
      emit(state.copyWith(selectedLanguage: language));
    }
  }

  Future<List<Country>> loadCountries() async {
    if (state.countries.isEmpty) {
      emit(state.copyWith(isCountriesLoading: true));

      RadioApi api = await RadioApi.create();
      List<Country> countries = [];
      var countriesList = await api.countries();
      for (var country in countriesList) {
        if (country['name'] == null ||
            (country['name'] as String).isEmpty ||
            country['iso_3166_1'] == null ||
            (country['iso_3166_1'] as String).length > 2) {
          continue;
        }
        String countryCode = (country['iso_3166_1'] as String).toUpperCase();
        Map<String, CountryInfo> map = ResManager.instance.countryMap;
        if (map.containsKey(countryCode)) {
          countries.add(Country.fromJson(country));
        }
      }
      emit(state.copyWith(countries: countries, isCountriesLoading: false));
      return countries;
    }
    return state.countries;
  }

  void selectCountry(String country) {
    if (state.selectedCountry != country) {
      emit(state.copyWith(selectedCountry: country, selectedState: ''));
    }
  }

  Future<List<CountryState>> loadStates() async {
    if (state.selectedCountry.isNotEmpty) {
      if (state.states.isEmpty || state.states[state.selectedCountry] == null) {
        emit(state.copyWith(isStateLoading: true));
        CountryInfo countryInfo =
            ResManager.instance.countryMap[state.selectedCountry];

        Map<String, String> r2lMap = ResManager.instance.cnR2LMap;

        RadioApi api = await RadioApi.create();
        // List<CountryState> countryStates = [];
        Map<String, CountryState> countryStatesMap = {};
        var countryStatesList =
            await api.states(country: countryInfo.name.toLowerCase());
        for (var countryState in countryStatesList) {
          if (countryState['name'] == null ||
              (countryState['name'] as String).isEmpty ||
              countryState['country'] == null ||
              (countryState['country'] as String).isEmpty) {
            continue;
          }
          String? mlState = r2lMap[countryState['name']];
          if (mlState != null) {
            CountryState? mState = countryStatesMap[mlState];
            CountryState tState = CountryState.fromJson(
                countryState, countryInfo.name, countryInfo.cca2);
            if (mState != null) {
              countryStatesMap[mlState] = CountryState(
                  country: countryInfo.name,
                  countrycode: countryInfo.cca2,
                  state: mlState,
                  stationcount: tState.stationcount + mState.stationcount);
            } else {
              tState = CountryState(
                  country: countryInfo.name,
                  countrycode: countryInfo.cca2,
                  state: mlState,
                  stationcount: tState.stationcount);
              // countryStates.add(tState);
              countryStatesMap[mlState] = tState;
            }
          }
        }
        var newState = Map.fromEntries(state.states.entries);
        List<CountryState> countryStates = countryStatesMap.values.toList();
        newState[state.selectedCountry] = countryStates;
        emit(state.copyWith(states: newState, isStateLoading: false));
        return countryStates;
      } else {
        return state.states[state.selectedCountry]!;
      }
    }
    return const [];
  }

  void selectState(String countryState) {
    if (state.selectedState != countryState) {
      emit(state.copyWith(selectedState: countryState));
    }
  }

  Future<List<Tag>> loadTags() async {
     if (state.tags.isEmpty) {
      emit(state.copyWith(isTagLoading: true));

      RadioApi api = await RadioApi.create();
      List<Tag> tags = [];
      var tagsList = await api.tags();
      for (var tag in tagsList) {
        if (tag['name'] == null ||
            (tag['name'] as String).isEmpty) {
          continue;
        }
        tags.add(Tag.fromJson(tag));
      }
      emit(state.copyWith(tags: tags, isTagLoading: false));
      return tags;
    }
    return state.tags;
  }
  void selectTag(List<String> tags) {
    if (state.selectedTags != tags) {
      emit(state.copyWith(selectedTags: tags));
    }
  }
}
