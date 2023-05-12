import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/record_state.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/pair.dart';

class RecordCubit extends Cubit<RecordState> {
  RecordCubit() : super(const RecordState());

  Future<List<Pair<Station, Record>>> loadRecord() async {
    emit(state.copyWith(
      isLoading: true,
    ));
    var records = await RadioRepository.instance.loadRecords();
    emit(state.copyWith(
      isLoading: false,
      records: records,
    ));

    return records;
  }

  void addRecord(Station station, String file) async {
    Record r = await RadioRepository.instance.addRecord(station, file);
    var records = await RadioRepository.instance.loadRecords();
    emit(state.copyWith(records: records, recordingId: r.id));
  }

  void updateRecord() async {
    if (state.recordingId != null) {
      await RadioRepository.instance.updateRecord(state.recordingId!);
      var records = await RadioRepository.instance.loadRecords();
      emit(state.copyWith(
        records: records,
      ));
    }
  }

  void delRecord(int recordId) async {
    await RadioRepository.instance.delRecord(recordId);
    var records = await RadioRepository.instance.loadRecords();
    emit(state.copyWith(
      records: records,
    ));
  }
}
