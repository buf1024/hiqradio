import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';

class AppState extends Equatable {
  final bool isInit;

  // playing
  final bool isPlaying;
  final bool isBuffering;
  final Station? playingStation;
  final bool isFavStation;

  final bool isEditing;

  final List<Language> languages;
  final Map<String, List<CountryState>> states;
  final List<Country> countries;
  final List<Tag> tags;

  final bool isLangLoading;
  final bool isStateLoading;
  final bool isCountriesLoading;
  final bool isTagLoading;

  const AppState({
    this.isInit = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.playingStation,
    this.isFavStation = false,
    this.isEditing = false,
    this.languages = const [],
    this.states = const {},
    this.countries = const [],
    this.tags = const [],
    this.isLangLoading = false,
    this.isStateLoading = false,
    this.isCountriesLoading = false,
    this.isTagLoading = false,
  });

  AppState copyWith({
    bool? isInit,
    bool? isPlaying,
    bool? isBuffering,
    Station? playingStation,
    bool? isFavStation,
    bool? isEditing,
    List<Language>? languages,
    Map<String, List<CountryState>>? states,
    List<Country>? countries,
    List<Tag>? tags,
    bool? isLangLoading,
    bool? isStateLoading,
    bool? isCountriesLoading,
    bool? isTagLoading,
  }) {
    return AppState(
      isInit: isInit ?? this.isInit,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      playingStation: playingStation ?? this.playingStation,
      isFavStation: isFavStation ?? this.isFavStation,
      isEditing: isEditing ?? this.isEditing,
      languages: languages ?? this.languages,
      states: states ?? this.states,
      countries: countries ?? this.countries,
      tags: tags ?? this.tags,
      isLangLoading: isLangLoading ?? this.isLangLoading,
      isStateLoading: isStateLoading ?? this.isStateLoading,
      isCountriesLoading: isCountriesLoading ?? this.isCountriesLoading,
      isTagLoading: isTagLoading ?? this.isTagLoading,
    );
  }

  @override
  List<Object?> get props => [
        isInit,
        isPlaying,
        isBuffering,
        playingStation,
        isFavStation,
        isEditing,
        languages,
        states,
        countries,
        tags,
        isLangLoading,
        isStateLoading,
        isCountriesLoading,
        isTagLoading,
      ];
}
