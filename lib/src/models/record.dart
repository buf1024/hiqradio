import 'package:equatable/equatable.dart';

class Record extends Equatable {
  final int? id;
  final String stationuuid;
  final int startTime;
  final int? endTime;
  final String? file;

  const Record({
    this.id,
    required this.stationuuid,
    required this.startTime,
    this.endTime,
    this.file,
  });

  factory Record.fromJson(dynamic map) {
    return Record(
      id: map['id'],
      stationuuid: map['stationuuid'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      file: map['file'],
    );
  }

  Record copyWith({
    int? id,
    String? stationuuid,
    int? startTime,
    int? endTime,
    String? file,
  }) {
    return Record(
      id: id ?? this.id,
      stationuuid: stationuuid ?? this.stationuuid,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      file: file ?? this.file,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'stationuuid': stationuuid,
      'start_time': startTime,
      'end_time': endTime,
      'file': file,
    };
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        stationuuid,
        startTime,
        endTime,
        file,
      ];
}
