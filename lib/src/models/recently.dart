import 'package:equatable/equatable.dart';

class Recently extends Equatable {
  final int? id;
  final String stationuuid;
  final int startTime;
  final int? endTime;

  const Recently({
    this.id,
    required this.stationuuid,
    required this.startTime,
    this.endTime,
  });

  factory Recently.fromJson(dynamic map) {
    return Recently(
      id: map['id'],
      stationuuid: map['stationuuid'],
      startTime: map['start_time'],
      endTime: map['end_time'],
    );
  }

  Recently copyWith({
    int? id,
    String? stationuuid,
    int? startTime,
    int? endTime,
  }) {
    return Recently(
      id: id ?? this.id,
      stationuuid: stationuuid ?? this.stationuuid,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'stationuuid': stationuuid,
      'start_time': startTime,
      'end_time': endTime,
    };
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        stationuuid,
        startTime,
        endTime,
      ];
}
