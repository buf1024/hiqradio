import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/recently_state.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/utils/constant.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyCubit extends Cubit<RecentlyState> {
  final RadioRepository repo = RadioRepository.instance;

  RecentlyCubit() : super(const RecentlyState());

  void setUserLogin(bool isLogin) {
    emit(state.copyWith(isLogin: isLogin));
  }

  Future<List<Pair<Station, Recently>>> loadRecently() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    int? pageSize = sp.getInt(kSpRCLastPageSize);
    pageSize ??= kDefPageSize;

    emit(state.copyWith(isLoading: true, pageSize: pageSize));
    var recentlys = await repo.loadRecently();
    emit(state.copyWith(
      isLoading: false,
      recentlys: recentlys,
    ));

    calcPage(recentlys, pageSize);

    return recentlys;
  }

  void calcPage(List<Pair<Station, Recently>> recentlys, int pageSize) {
    int totalSize = recentlys.length;
    int page = state.page;
    int totalPage = state.totalPage;
    if (pageSize > 0) {
      totalPage = totalSize ~/ state.pageSize;
      if (totalSize % state.pageSize > 0) {
        totalPage += 1;
      }
      page = 1;
    }

    emit(state.copyWith(
      totalSize: totalSize,
      totalPage: totalPage,
      page: page,
    ));
  }

  void changePageSize(int pageSize) async {
    if (state.pageSize != pageSize &&
        pageSize > 0 &&
        pageSize <= kMaxPageSize &&
        !state.isLoading) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      sp.setInt(kSpRCLastPageSize, pageSize);

      int totalPage = (state.totalSize / pageSize).truncate();
      if (state.totalSize % pageSize > 0) {
        totalPage += 1;
      }
      int page = 1;
      emit(
          state.copyWith(pageSize: pageSize, totalPage: totalPage, page: page));
    }
  }

  void changePage(int page) {
    if (state.page != page &&
        page > 0 &&
        page <= state.totalPage &&
        !state.isLoading) {
      emit(state.copyWith(page: page));
    }
  }

  void addRecently(Station station) async {
    await repo.addRecently(station);
    var recentlys = await repo.loadRecently();
    emit(state.copyWith(
      recentlys: recentlys,
    ));
    calcPage(recentlys, state.pageSize);

    if (recentlys.isNotEmpty && state.isLogin) {
      List<Recently> recently = List.filled(1, state.recentlys[0].p2);
      await repo.userApi.radioRecentlyNew(recently);
    }
  }

  void updateRecently(Station station) async {
    if (state.recentlys.isNotEmpty) {
      Recently recently = state.recentlys[0].p2;
      Station pStation = state.recentlys[0].p1;
      if (station.urlResolved == pStation.urlResolved &&
          recently.endTime == null) {
        await repo.updateRecently(recently.id!);
        var recentlys = await repo.loadRecently();
        emit(state.copyWith(
          recentlys: recentlys,
        ));

        if (recentlys.isNotEmpty && state.isLogin) {
          Recently recently = state.recentlys[0].p2;
          await repo.userApi.radioRecentlyModify(recently);
        }
      }
    }
  }

  void clearRecently() async {
    await repo.clearRecently();
    emit(state.copyWith(
      recentlys: const [],
    ));
    calcPage(const [], state.pageSize);

    if (state.isLogin) {
      await repo.userApi.radioRecentlyClear();
    }
  }
}
