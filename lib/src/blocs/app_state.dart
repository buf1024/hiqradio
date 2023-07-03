import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hiqradio/src/models/country.dart';
import 'package:hiqradio/src/models/country_state.dart';
import 'package:hiqradio/src/models/language.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/models/tag.dart';
import 'package:hiqradio/src/utils/constant.dart';

class AppState extends Equatable {
  final bool isInit;
  final String expireDate;
  final bool isTry;

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

  final bool isRecording;
  final Record? playingRecord;

  final HiqThemeMode themeMode;

  final List<Station> playHis;
  final int playHisIndex;

  final bool autoStart;
  final bool autoStop;

  final bool autoCache;

  final String locale;

  final int stopTimer;
  final bool isCaching;

  const AppState({
    this.isTry = true,
    this.expireDate = '',
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
    this.themeMode = HiqThemeMode.dark,
    this.isRecording = false,
    this.playingRecord,
    this.playHis = const [],
    this.playHisIndex = 0,
    this.autoStart = false,
    this.autoStop = true,
    this.autoCache = true,
    this.locale = '',
    this.stopTimer = -1,
    this.isCaching = false,
  });

  AppState copyWith({
    bool? isTry,
    String? expireDate,
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
    HiqThemeMode? themeMode,
    bool? isRecording,
    Record? playingRecord,
    List<Station>? playHis,
    int? playHisIndex,
    bool? autoStart,
    bool? autoStop,
    bool? autoCache,
    String? locale,
    int? stopTimer,
    bool? isCaching
  }) {
    return AppState(
      isTry: isTry ?? this.isTry,
      expireDate: expireDate ?? this.expireDate,
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
      themeMode: themeMode ?? this.themeMode,
      isRecording: isRecording ?? this.isRecording,
      playingRecord: playingRecord,
      playHis: playHis ?? this.playHis,
      playHisIndex: playHisIndex ?? this.playHisIndex,
      autoStart: autoStart ?? this.autoStart,
      autoStop: autoStop ?? this.autoStop,
      autoCache: autoCache ?? this.autoCache,
      locale: locale ?? this.locale,
      stopTimer: stopTimer ?? this.stopTimer,
      isCaching: isCaching ?? this.isCaching,
    );
  }

  ThemeMode get hiqThemMode => kThemeMode[themeMode]!;

  @override
  List<Object?> get props => [
        isTry,
        expireDate,
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
        themeMode,
        isRecording,
        playingRecord,
        playHis,
        playHisIndex,
        autoStart,
        autoStop,
        autoCache,
        locale,
        stopTimer,
        isCaching
      ];
}
