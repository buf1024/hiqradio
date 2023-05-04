import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/tag.dart';

class SearchOptState extends Equatable {
  final List<Language> languages;
  final Map<String, List<CountryState>> states;
  final List<Country> countries;
  final List<Tag> tags;

  final bool isLangLoading;
  final bool isStateLoading;
  final bool isCountriesLoading;
  final bool isTagLoading;

  final List<String> selectedTags;
  final String selectedLanguage;
  final String selectedCountry;
  final String selectedState;

  const SearchOptState({
    this.languages = const [],
    this.states = const {},
    this.countries = const [],
    this.tags = const [],
    this.isLangLoading = false,
    this.isStateLoading = false,
    this.isCountriesLoading = false,
    this.isTagLoading = false,
    this.selectedTags = const [],
    this.selectedLanguage = '',
    this.selectedCountry = '',
    this.selectedState = '',
  });

  SearchOptState copyWith({
    List<Language>? languages,
    Map<String, List<CountryState>>? states,
    List<Country>? countries,
    List<Tag>? tags,
    bool? isLangLoading,
    bool? isStateLoading,
    bool? isCountriesLoading,
    bool? isTagLoading,
    List<String>? selectedTags,
    String? selectedLanguage,
    String? selectedCountry,
    String? selectedState,
  }) {
    return SearchOptState(
      languages: languages ?? this.languages,
      states: states ?? this.states,
      countries: countries ?? this.countries,
      tags: tags ?? this.tags,
      isLangLoading: isLangLoading ?? this.isLangLoading,
      isStateLoading: isStateLoading ?? this.isStateLoading,
      isCountriesLoading: isCountriesLoading ?? this.isCountriesLoading,
      isTagLoading: isTagLoading ?? this.isTagLoading,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedState: selectedState ?? this.selectedState,
    );
  }

  @override
  List<Object?> get props => [
        languages,
        states,
        countries,
        tags,
        isLangLoading,
        isStateLoading,
        isCountriesLoading,
        isTagLoading,
        selectedTags,
        selectedLanguage,
        selectedCountry,
        selectedState,
      ];
}
