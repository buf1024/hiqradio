import 'package:equatable/equatable.dart';

class CountryState extends Equatable {
  final String? country;
  final String? countrycode;
  final String? state;
  final int stationcount;

  const CountryState(
      {this.country, this.countrycode, this.state, required this.stationcount});

  factory CountryState.fromJson(
      dynamic map, final String? country, final String? countrycode) {
    return CountryState(
        state: map['name'],
        country: country,
        countrycode: countrycode,
        stationcount: map['stationcount']);
  }

  @override
  List<Object?> get props => [country, countrycode, state, stationcount];
}
