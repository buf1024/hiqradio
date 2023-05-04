import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final int? id;
  final String stationuuid;
  final String name;
  final String urlResolved;
  final String? homepage;
  final String? favicon;
  final String? tags;
  final String? country;
  final String? countrycode;
  final String? state;
  final String? language;
  final String? codec;
  final int? bitrate;

  const Station(
      {this.id,
      required this.stationuuid,
      required this.name,
      required this.urlResolved,
      this.homepage,
      this.favicon,
      this.tags,
      this.country,
      this.countrycode,
      this.state,
      this.language,
      this.codec,
      this.bitrate});

  factory Station.fromJson(dynamic map) {
    return Station(
        stationuuid: map['stationuuid'],
        name: map['name'],
        urlResolved: map['url_resolved'],
        homepage: map['homepage'],
        favicon: map['favicon'],
        tags: map['tags'],
        country: map['country'],
        countrycode: map['countrycode'],
        state: map['state'],
        language: map['language'],
        codec: map['codec'],
        bitrate: map['bitrate']);
  }

  @override
  List<Object?> get props => [stationuuid];
}
