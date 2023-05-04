import 'package:equatable/equatable.dart';

class Language extends Equatable {
  final int? id;
  final String? language;
  final String? languagecode;
  final int stationcount;

  const Language(
      {this.id, this.language, this.languagecode, required this.stationcount});

  factory Language.fromJson(dynamic map) {
    return Language(
        language: map['name'],
        languagecode: (map['iso_639'] as String).toLowerCase(),
        stationcount: map['stationcount']);
  }

  @override
  List<Object?> get props => [id, language, languagecode, stationcount];
}
