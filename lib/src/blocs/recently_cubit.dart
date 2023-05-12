import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/recently_state.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/pair.dart';

class RecentlyCubit extends Cubit<RecentlyState> {
  RecentlyCubit() : super(const RecentlyState());

  Future<List<Pair<Station, Recently>>> loadRecently() async {
    emit(state.copyWith(
      isLoading: true,
    ));
    var recentlys = await RadioRepository.instance.loadRecently();
    emit(state.copyWith(
      isLoading: false,
      recentlys: recentlys,
    ));

    return recentlys;
  }

  void addRecently(Station station) async {
    await RadioRepository.instance.addRecently(station);
    var recentlys = await RadioRepository.instance.loadRecently();
    emit(state.copyWith(
      recentlys: recentlys,
    ));
  }

  void updateRecently(Station station) async {
    if (state.recentlys.isNotEmpty) {
      Recently recently = state.recentlys[0].p2;
      Station pStation = state.recentlys[0].p1;
      if (station.urlResolved == pStation.urlResolved &&
          recently.endTime == null) {
        await RadioRepository.instance.updateRecently(recently.id!);
        var recentlys = await RadioRepository.instance.loadRecently();
        emit(state.copyWith(
          recentlys: recentlys,
        ));
      }
    }
  }

  void clearRecently() async {
    await RadioRepository.instance.clearRecently();
    emit(state.copyWith(
      recentlys: const [],
    ));
  }
}
