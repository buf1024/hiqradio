import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database;

class RadioDao {
  final Database db;
  RadioDao({required this.db});

  Future<FavGroup?> queryGroup({required String name}) async {
    List<Map<String, Object?>> data = await db.query('fav_group',
        where: 'name = ?', whereArgs: [name], limit: 1);
    if (data.isNotEmpty) {
      return FavGroup.fromJson(data[0]);
    }
    return null;
  }

  Future<FavGroup?> queryDefGroup() async {
    List<Map<String, Object?>> data = await db.query('fav_group',
        where: 'is_def = ?', whereArgs: [1], limit: 1);
    if (data.isNotEmpty) {
      return FavGroup.fromJson(data[0]);
    }
    return null;
  }

  Future<List<FavGroup>?> queryGroups() async {
    List<Map<String, Object?>> data = await db.query('fav_group');
    if (data.isNotEmpty) {
      List<FavGroup> groups = [];
      for (var map in data) {
        groups.add(FavGroup.fromJson(map));
      }
      return groups;
    }
    return null;
  }

  Future<void> updateGroup(int id, {String? name, String? desc}) async {
    if (name != null || desc != null) {
      Map<String, Object?> values = {};
      if (name != null) {
        values['name'] = name;
      }
      if (desc != null) {
        values['desc'] = desc;
      }
      if (values.isNotEmpty) {
        db.update('fav_group', values, where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<FavGroup> insertNewGroup() async {
    return await db.transaction((txn) async {
      List<Map<String, Object?>> data =
          await txn.rawQuery('select max(id) as max_id from fav_group');
      assert(data.isNotEmpty);
      var maxId = data[0]['max_id'] as int;
      String name = '新增分组#${maxId + 1}';
      while (true) {
        var rs =
            await txn.query('fav_group', where: 'name = ?', whereArgs: [name]);
        if (rs.isNotEmpty) {
          name = '新增分组#${maxId + 1}';
          continue;
        }
        break;
      }
      Map<String, Object?> values = {
        'name': name,
        'desc': '新增的分组',
        'create_time': DateTime.now().millisecondsSinceEpoch,
        'is_def': 0
      };
      await txn.insert('fav_group', values);
      var rs =
          await txn.query('fav_group', where: 'name = ?', whereArgs: [name]);
      assert(rs.isNotEmpty);
      return FavGroup.fromJson(rs[0]);
    });
  }

  Future<void> changeGroup(
      String stationuuid, String oldGroup, List<String> newGroups) async {
    return await db.transaction((txn) async {
      var gList = await txn
          .query('fav_group', where: 'name = ?', whereArgs: [oldGroup]);
      if (gList.isNotEmpty) {
        var oldGroupId = gList[0]['id'];
        await txn.delete('favorite',
            where: 'stationuuid = ? and group_id = ?',
            whereArgs: [stationuuid, oldGroupId]);
        for (var newGroup in newGroups) {
          gList = await txn
              .query('fav_group', where: 'name = ?', whereArgs: [newGroup]);
          if (gList.isEmpty) {
            continue;
          }
          var newGroupId = gList[0]['id'];
          var list = await txn.query('favorite',
              where: 'stationuuid = ? and group_id = ?',
              whereArgs: [stationuuid, newGroupId]);
          if (list.isEmpty) {
            Map<String, Object?> values = {
              'stationuuid': stationuuid,
              'group_id': newGroupId
            };
            await txn.insert('favorite', values);
          }
        }
      }
    });
  }

  Future<void> delGroup(String name) async {
    await db.transaction((txn) async {
      List<Map<String, Object?>> list = await txn.query('fav_group',
          where: 'name = ?', whereArgs: [name], limit: 1);
      if (list.isNotEmpty) {
        Map<String, Object?> group = list[0];
        await txn.delete('favorite',
            where: 'group_id = ?', whereArgs: [group['id']]);
        await txn
            .delete('fav_group', where: 'id = ?', whereArgs: [group['id']]);
      }
    });
  }

  Future<List<FavGroup>> queryStationGroup(String stationuuid) async {
    var data = await db.rawQuery(
        'select a.* from fav_group a left join favorite b on a.id = b.group_id where b.stationuuid = ?',
        [stationuuid]);
    return data.map((e) => FavGroup.fromJson(e)).toList();
  }

  Future<List<Station>?> queryFavStations(String groupName) async {
    List<Map<String, Object?>> data = await db.rawQuery(
        'select a.* from station a, favorite b, fav_group c where a.stationuuid = b.stationuuid and b.group_id = c.id and c.name = ? order by id',
        [groupName]);
    if (data.isNotEmpty) {
      return data.map((e) => Station.fromJson(e)).toList();
    }
    return null;
  }

  Future<Station?> queryStation(String stationuuid) async {
    List<Map<String, Object?>> data = await db.query('station',
        where: 'stationuuid = ?', whereArgs: [stationuuid], limit: 1);
    List<Station> stations = data.map(Station.fromJson).toList();
    return stations.isNotEmpty ? stations[0] : null;
  }

  Future<bool> queryIsFavStation(String stationuuid, int groupId) async {
    List<Map<String, Object?>> data = await db.rawQuery(
        'select a.* from favorite a where a.group_id = ? and a.stationuuid = ?',
        [groupId, stationuuid]);
    return data.isNotEmpty;
  }

  Future<void> insertFavorite(Station station, int groupId) async {
    db.transaction((txn) async {
      List<Map<String, Object?>> list = await txn.query('station',
          where: 'stationuuid = ?', whereArgs: [station.stationuuid], limit: 1);
      if (list.isEmpty) {
        var jsValues = station.toJson();
        await txn.insert('station', jsValues);

        Map<String, Object?> values = {
          'stationuuid': station.stationuuid,
          'group_id': groupId
        };
        await txn.insert('favorite', values);
      }
    });
  }

  Future<int> delFavorite(String stationuuid) async {
    return db
        .delete('favorite', where: 'stationuuid = ?', whereArgs: [stationuuid]);
  }

  Future<int> delFavorites(int groupId) async {
    return db.delete('favorite', where: 'group_id = ?', whereArgs: [groupId]);
  }

  Future<List<Recently>> queryRecently() async {
    List<Map<String, Object?>> data =
        await db.query('recently', orderBy: 'start_time desc');
    return data.map(Recently.fromJson).toList();
  }

  Future<void> insertRecently(Station station) async {
    db.transaction((txn) async {
      List<Map<String, Object?>> list = await txn.query('station',
          where: 'stationuuid = ?', whereArgs: [station.stationuuid], limit: 1);
      if (list.isEmpty) {
        var jsValues = station.toJson();
        await txn.insert('station', jsValues);
      }
      Map<String, Object?> values = {
        'stationuuid': station.stationuuid,
        'start_time': DateTime.now().millisecondsSinceEpoch
      };
      await txn.insert('recently', values);
    });
  }

  Future<int> updateRecently(int recentlyId) async {
    return db.update(
        'recently', {'end_time': DateTime.now().millisecondsSinceEpoch},
        where: 'id =?', whereArgs: [recentlyId]);
  }

  Future<int> delRecently() async {
    return db.delete('recently', where: '1 = ?', whereArgs: [1]);
  }
}
