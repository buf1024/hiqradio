import 'package:equatable/equatable.dart';

class Language extends Equatable {
  final String? language;
  final String? languagecode;
  final int stationcount;

  const Language(
      {this.language, this.languagecode, required this.stationcount});

  factory Language.fromJson(dynamic map) {
    return Language(
        language: map['name'],
        languagecode: (map['iso_639'] as String).toLowerCase(),
        stationcount: map['stationcount']);
  }

  @override
  List<Object?> get props => [language, languagecode, stationcount];
}
