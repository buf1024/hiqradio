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
        name: (map['name'] as String).trim(),
        urlResolved: map['url_resolved'],
        homepage: map['homepage'],
        favicon: map['favicon'],
        tags:
            map['tags'] != null ? (map['tags'] as String).trim() : map['tags'],
        country: map['country'],
        countrycode: map['countrycode'],
        state: map['state'],
        language: map['language'],
        codec: map['codec'],
        bitrate: map['bitrate']);
  }

  Station copyWith({
    int? id,
    String? stationuuid,
    String? name,
    String? urlResolved,
    String? homepage,
    String? favicon,
    String? tags,
    String? country,
    String? countrycode,
    String? state,
    String? language,
    String? codec,
    int? bitrate,
  }) {
    return Station(
      id: id ?? this.id,
      stationuuid: stationuuid ?? this.stationuuid,
      name: name ?? this.name,
      urlResolved: urlResolved ?? this.urlResolved,
      homepage: homepage ?? this.homepage,
      favicon: favicon ?? this.favicon,
      tags: tags ?? this.tags,
      country: country ?? this.country,
      countrycode: countrycode ?? this.countrycode,
      state: state ?? this.state,
      language: language ?? this.language,
      codec: codec ?? this.codec,
      bitrate: bitrate ?? this.bitrate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        stationuuid,
        name,
        urlResolved,
        homepage,
        favicon,
        tags,
        country,
        countrycode,
        state,
        language,
        codec,
        bitrate
      ];
}
