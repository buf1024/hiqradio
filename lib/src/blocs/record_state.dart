import 'package:equatable/equatable.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';

class RecordState extends Equatable {
  final bool isLoading;
  final List<Pair<Station, Record>> records;
  final int? recordingId;

  const RecordState({
    this.isLoading = true,
    this.records = const [],
    this.recordingId, 
  });

  RecordState copyWith({
    bool? isLoading,
    List<Pair<Station, Record>>? records,
    int? recordingId, 
  }) {
    return RecordState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      recordingId: recordingId?? this.recordingId
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        records,
        recordingId,
      ];
}
