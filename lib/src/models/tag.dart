import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final int? id;
  final String? tag;
  final int stationcount;

  const Tag(
      {this.id, this.tag, required this.stationcount});

  factory Tag.fromJson(dynamic map) {
    return Tag(
        tag: map['name'],
        stationcount: map['stationcount']);
  }

  @override
  List<Object?> get props => [id, tag, stationcount];
}
