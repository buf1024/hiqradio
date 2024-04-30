import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/favorite_state.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/repository/repository.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  RadioRepository repo = RadioRepository.instance;
  FavoriteCubit() : super(const FavoriteState());
  String? getLoadedGroup() {
    if (state.group != null) {
      return state.group!.name;
    }
    return null;
  }

  void setUserLogin(bool isLogin) {
    emit(state.copyWith(isLogin: isLogin));
  }

  void updateGroup(String name, String desc) async {
    if (state.group != null) {
      bool isUpdated = false;
      if (state.group!.name == name) {
        isUpdated = true;
      } else {
        FavGroup? g = await repo.loadGroup(groupName: name);
        if (g == null) {
          isUpdated = true;
        }
      }
      if (isUpdated) {
        await repo.updateGroup(state.group!.id!, name: name, desc: desc);
        if (state.isLogin) {
          await repo.userApi.radioGroupModify(state.group!.name, name, desc);
        }

        FavGroup? group = await repo.loadGroup(groupName: name);
        List<FavGroup> groups = await repo.loadGroups();
        emit(state.copyWith(group: group, groups: groups));
      }
    }
  }

  Future<FavGroup> addNewGroup() async {
    FavGroup group = await repo.addNewGroup();
    List<FavGroup> groups = await repo.loadGroups();
    emit(state.copyWith(group: group, groups: groups, stations: []));

    if (state.isLogin) {
      List<FavGroup> favGroups = List.filled(1, group);
      await repo.userApi.radioGroupNew(favGroups);
    }

    return group;
  }

  void deleteGroup(FavGroup group) async {
    await repo.delGroup(group.name);
    if (state.isLogin) {
      List<FavGroup> param = List.filled(1, group);
      await repo.userApi.radioGroupDelete(param);
    }
    List<FavGroup> groups = await repo.loadGroups();
    if (state.group != null && state.group!.name == group.name) {
      FavGroup? group = await repo.loadGroup();
      emit(state.copyWith(group: group, groups: groups));
      await loadFavorite(groupName: group!.name);
    } else {
      emit(state.copyWith(groups: groups));
    }
  }

  void switchGroup(FavGroup group) async {
    if (state.group != null && state.group!.name != group.name) {
      emit(state.copyWith(group: group));
      await loadFavorite(groupName: group.name);
    }
  }

  void loadGroups() async {
    emit(state.copyWith(isGroupsLoading: true));
    List<FavGroup> groups = await repo.loadGroups();
    emit(state.copyWith(groups: groups, isGroupsLoading: false));
  }

  Future<List<String>> loadStationGroup(Station station) async {
    return await repo.loadStationGroup(station.stationuuid);
  }

  void changeGroup(
      Station station, String oldGroup, List<String> newGroups) async {
    await repo.changeGroup(station.stationuuid, oldGroup, newGroups);
    await loadFavorite(groupName: state.group?.name);

    if (state.isLogin) {
      await repo.userApi.radioFavoriteDelete([], [oldGroup]);
      List<Map<String, dynamic>> param = List.empty(growable: true);
      for (var group in newGroups) {
        Map<String, dynamic> map = {
          "group_name": group,
          "stationuuid": station.stationuuid,
          "create_time": DateTime.now().millisecondsSinceEpoch
        };
        param.add(map);
      }
      await repo.userApi.radioFavoriteNew(param);
    }
  }

  Future<void> loadFavorite({String? groupName}) async {
    emit(state.copyWith(isLoading: true));
    FavGroup? group = await repo.loadGroup(groupName: groupName);
    List<Station> stations = [];
    if (group != null) {
      // List<Station>? ss = await repo.loadFavStations(group.name);
      // if (ss != null) {
      //   stations = ss;
      // }

      List<String>? uuids = await repo.loadFavStationsNotCheck(group.name);
      if (uuids != null) {
        for (var uuid in uuids) {
          Station? s = await repo.dao.queryStation(uuid);
          if (s == null) {
            List<dynamic> list = await repo.api.stationsByUuid(uuid: uuid);
            if (list.isEmpty) {
              continue;
            }
            s = Station.fromJson(list[0]);
            repo.dao.insertStation(s);
          }
          stations.add(s);
        }
      }
    }
    emit(state.copyWith(group: group, stations: stations, isLoading: false));
  }

  void addFavorite(String? groupName, Station station) async {
    FavGroup? group = await repo.loadGroup(groupName: groupName);

    if (group != null) {
      bool isFav = await repo.isFavStation(station.stationuuid, group.id!);
      if (!isFav) {
        await repo.addFavorite(station, group.id!);
        if (state.group != null && state.group!.name == group.name) {
          List<Station> stations = List.from(state.stations);
          stations.add(station);
          emit(state.copyWith(stations: stations));
        }
        if (state.isLogin) {
          Map<String, Object> values = {
            'stationuuid': station.stationuuid,
            'group_name': group.name,
            'create_time': DateTime.now().millisecondsSinceEpoch
          };
          List<Map<String, Object>> param = List.filled(1, values);

          await repo.userApi.radioFavoriteNew(param);
        }
      }
    }
  }

  void delFavorite(Station station) async {
    await repo.delFavorite(station.stationuuid);
    if (state.isLogin) {
      await repo.userApi.radioFavoriteDelete([station.stationuuid], []);
    }
    List<Station> stations = [];
    for (var s in state.stations) {
      if (s.stationuuid == station.stationuuid) {
        continue;
      }
      stations.add(s);
    }
    if (state.stations.length != stations.length) {
      emit(state.copyWith(stations: stations));
    }
  }

  void clearFavorite(int groupId) async {
    await repo.clearFavorites(groupId);

    emit(state.copyWith(stations: []));
    if (state.isLogin) {
      FavGroup? group = await repo.dao.queryGroupById(groupId);
      if (group != null) {
        await repo.userApi.radioFavoriteDelete([], [group.name]);
      }
    }
  }

  Future<String> exportFavJson() async {
    return await repo.loadExportJson();
  }

  Future<void> importFavJson(List<dynamic> jsObj) async {
    await repo.saveImportJson(jsObj);
    String? groupName = getLoadedGroup();
    await loadFavorite(groupName: groupName);
    loadGroups();
  }
}
