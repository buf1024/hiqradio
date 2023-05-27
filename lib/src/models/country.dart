import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String? country;
  final String? countrycode;
  final int stationcount;

  const Country(
      {this.country, this.countrycode, required this.stationcount});

  factory Country.fromJson(dynamic map) {
    return Country(
        country: map['name'],
        countrycode: (map['iso_3166_1'] as String).toUpperCase(),
        stationcount: map['stationcount']);
  }

  @override
  List<Object?> get props => [country, countrycode, stationcount];
}
