import 'dart:collection';
import 'dart:convert';

import 'package:hiqradio/src/models/cache.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:hiqradio/src/models/record.dart';
import 'package:hiqradio/src/models/station.dart';
import 'package:hiqradio/src/utils/pair.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database;

class RadioDao {
  final Database db;
  final int kBatchSize = 500;

  int isLogin = 0;
  RadioDao({required this.db});

  void setIsLogin(bool login) {
    isLogin = login ? 1 : 0;
  }

  Future<FavGroup?> queryGroup({required String name}) async {
    List<Map<String, Object?>> data = await db.query('fav_group',
        where: 'name = ?', whereArgs: [name], limit: 1);
    if (data.isNotEmpty) {
      return FavGroup.fromJson(data[0]);
    }
    return null;
  }

  Future<FavGroup?> queryGroupById(int groupId) async {
    List<Map<String, Object?>> data = await db.query('fav_group',
        where: 'id = ?', whereArgs: [groupId], limit: 1);
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

  Future<List<FavGroup>?> queryNotLoginGroups() async {
    List<Map<String, Object?>> data =
        await db.query('fav_group', where: 'is_login = 0');
    if (data.isNotEmpty) {
      List<FavGroup> groups = [];
      for (var map in data) {
        groups.add(FavGroup.fromJson(map));
      }
      return groups;
    }
    return null;
  }

  Future<List<Recently>?> queryNotLoginRecently() async {
    List<Map<String, Object?>> data =
        await db.query('recently', where: 'is_login = 0');
    if (data.isNotEmpty) {
      List<Recently> recently = [];
      for (var map in data) {
        recently.add(Recently.fromJson(map));
      }
      return recently;
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
        values['create_time'] = DateTime.now().millisecondsSinceEpoch;
        values['is_login'] = isLogin;

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
        'is_def': 0,
        'is_login': isLogin
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
        // var oldGroupId = gList[0]['id'];
        // await txn.delete('favorite',
        //     where: 'stationuuid = ? and group_id = ?',
        //     whereArgs: [stationuuid, oldGroupId]);
        await txn.delete('favorite',
            where: 'stationuuid = ?', whereArgs: [stationuuid]);
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
              'group_id': newGroupId,
              'create_time': DateTime.now().millisecondsSinceEpoch,
              'is_login': isLogin
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

  Future<String> queryExportJson() async {
    List<Map<String, Object?>> data = await db.query('fav_group');
    if (data.isNotEmpty) {
      List<Map<String, Object?>> jsObj = [];
      for (var group in data) {
        String groupName = group['name'] as String;

        List<Map<String, Object?>> stations = await db.rawQuery(
            'select a.*, b.create_time from station a, favorite b, fav_group c where a.stationuuid = b.stationuuid and b.group_id = c.id and c.name = ? order by id',
            [groupName]);

        jsObj.add({'group': group, 'stations': stations});
      }
      return jsonEncode(jsObj);
    }
    return "[]";
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
      }
      Map<String, Object?> values = {
        'stationuuid': station.stationuuid,
        'group_id': groupId,
        'create_time': DateTime.now().millisecondsSinceEpoch,
        'is_login': isLogin,
      };
      await txn.insert('favorite', values);
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
        await db.query('recently', orderBy: 'start_time desc', limit: 500);
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
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'is_login': isLogin
      };
      await txn.insert('recently', values);
    });
  }

  Future<int> updateRecently(int recentlyId) async {
    return db.update(
        'recently',
        {
          'end_time': DateTime.now().millisecondsSinceEpoch,
          'is_login': isLogin,
        },
        where: 'id =?',
        whereArgs: [recentlyId]);
  }

  Future<int> delRecently() async {
    return db.delete('recently', where: '1 = ?', whereArgs: [1]);
  }

  // record
  Future<List<Record>> queryRecord() async {
    List<Map<String, Object?>> data =
        await db.query('record', orderBy: 'start_time desc');
    return data.map(Record.fromJson).toList();
  }

  Future<Record> insertRecord(Station station, String file) async {
    db.transaction((txn) async {
      List<Map<String, Object?>> list = await txn.query('station',
          where: 'stationuuid = ?', whereArgs: [station.stationuuid], limit: 1);
      if (list.isEmpty) {
        var jsValues = station.toJson();
        await txn.insert('station', jsValues);
      }
      Map<String, Object?> values = {
        'stationuuid': station.stationuuid,
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'file': file
      };
      await txn.insert('record', values);
    });
    List<Map<String, Object?>> data = await db.query('record',
        where: 'stationuuid = ? and file = ?',
        whereArgs: [station.stationuuid, file]);
    assert(data.length == 1);

    return Record.fromJson(data[0]);
  }

  Future<int> updateRecord(int recordId) async {
    return db.update(
        'record', {'end_time': DateTime.now().millisecondsSinceEpoch},
        where: 'id =?', whereArgs: [recordId]);
  }

  Future<int> delRecord(int recordId) async {
    return db.delete('record', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<Station?> queryRandomStation() async {
    List<Map<String, Object?>> data =
        await db.rawQuery('select * from station order by random() limit 1');
    if (data.isNotEmpty) {
      return Station.fromJson(data[0]);
    }
    return null;
  }

  Future<int> queryStationCount() async {
    List<Map<String, Object?>> data =
        await db.rawQuery("SELECT COUNT(*) as count from station");

    if (data.isNotEmpty) {
      Map<String, Object?> m = data.first;
      return m['count']! as int;
    }

    return 0;
  }

  Future<List<Map<String, Object?>>> queryStationCountByLanguage() async {
    return await db.rawQuery(
        "SELECT  DISTINCT language as language, COUNT(*) as count from station where language is not null and language != '' GROUP BY language");
  }

  Future<List<Map<String, Object?>>> queryStationCountByCountrycode() async {
    return await db.rawQuery(
        "SELECT  DISTINCT countrycode as countrycode, COUNT(*) as count from station where countrycode is not null and countrycode != ''  GROUP BY countrycode");
  }

  Future<List<Map<String, Object?>>> queryStationCountByState(
      String country) async {
    return await db.rawQuery(
        "SELECT  DISTINCT state as name, country, COUNT(*) as stationcount from station where state is not null and state != ''  and country like ?  GROUP BY state",
        ['%$country%']);
  }

  Future<List<Map<String, Object?>>> queryStationCountByTags() async {
    return await db.rawQuery(
        "SELECT  DISTINCT tags as tags , COUNT(*) as count from station where tags is not null and tags != ''  GROUP BY tags");
  }

  Future<dynamic> querySearchStation(
      {String? name,
      String? country,
      String? state,
      String? language,
      String? tagList}) async {
    String condition = '';
    bool hasCond = false;
    if (name != null && name.isNotEmpty) {
      condition +=
          "(name like '%$name%' or tags like '%$name%' or country like '%$name%' or state like '%$name%' or language like '%$name%')";
      hasCond = true;
    }

    if (country != null && country.isNotEmpty) {
      if (hasCond) {
        condition += " and";
      }
      condition += " country like '%$country%'";
      hasCond = true;
    }
    if (state != null && state.isNotEmpty) {
      if (hasCond) {
        condition += " and";
      }
      condition += " state like '%$state%'";
      hasCond = true;
    }
    if (language != null && language.isNotEmpty) {
      if (hasCond) {
        condition += " and";
      }
      condition += " language like '%$language%'";
      hasCond = true;
    }
    if (tagList != null && tagList.isNotEmpty) {
      if (hasCond) {
        condition += " and";
      }
      condition += " tags like '%$tagList%'";
      hasCond = true;
    }
    if (hasCond) {
      condition = ' where $condition';
    }

    return await db.rawQuery('select * from station $condition');
  }

  Future<Cache?> queryCache() async {
    List<Map<String, Object?>> data = await db.query('cache',
        where: 'tab = ?', whereArgs: ['station'], limit: 1);
    if (data.isNotEmpty) {
      return Cache.fromJson(data[0]);
    }
    return null;
  }

  Future<int> updateCache(int id, int checkTime) async {
    return await db.update('cache', {'check_time': checkTime},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<Cache> insertCache() async {
    return await db.transaction((txn) async {
      Cache cache = Cache(
          tab: 'favorite', checkTime: DateTime.now().millisecondsSinceEpoch);
      await txn.insert('cache', cache.toJson());
      List<Map<String, Object?>> data = await txn.query('cache',
          where: 'tab = ?', whereArgs: ['station'], limit: 1);
      assert(data.isNotEmpty);
      return Cache.fromJson(data[0]);
    });
  }

  Future<void> insertFavImport(
      List<Pair<FavGroup, List<Pair<Station, int>>>> data) async {
    await db.transaction((txn) async {
      for (Pair<FavGroup, List<Pair<Station, int>>> gs in data) {
        FavGroup group = gs.p1;

        List<Map<String, Object?>> data;
        if (group.id != 1) {
          data = await txn.query('fav_group',
              where: 'name = ?', whereArgs: [group.name], limit: 1);
          if (data.isNotEmpty) {
            group = FavGroup(
              id: data[0]['id'] as int?,
              createTime: group.createTime,
              name: group.name,
              desc: group.desc,
              isDef: group.isDef,
              isLogin: isLogin,
            );
            // await txn.update('fav_group', group.toJson(),
            //     where: 'id = ?', whereArgs: [group.id]);
          } else {
            group = FavGroup(
              id: null,
              createTime: group.createTime,
              name: group.name,
              desc: group.desc,
              isDef: group.isDef,
              isLogin: isLogin,
            );
            await txn.insert('fav_group', group.toJson());

            data = await txn.query('fav_group',
                where: 'name = ?', whereArgs: [group.name], limit: 1);
            group = FavGroup.fromJson(data[0]);
          }
        }

        List<Pair<Station, int>> stationsTimes = gs.p2;
        for (Pair<Station, int> st in stationsTimes) {
          Station s = st.p1;
          int createTime = st.p2;

          data = await txn.rawQuery(
              'select a.* from favorite a where a.group_id = ? and a.stationuuid = ?',
              [group.id, s.stationuuid]);
          if (data.isEmpty) {
            Map<String, Object?> values = {
              'stationuuid': s.stationuuid,
              'group_id': group.id,
              'create_time': createTime,
              'is_login': isLogin
            };
            await txn.insert('favorite', values);
          }

          data = await txn.query('station',
              where: 'stationuuid = ?', whereArgs: [s.stationuuid], limit: 1);

          if (data.isEmpty) {
            await txn.insert('station', s.toJson(withId: false));
          }
        }
      }
    });
  }

  Future<void> insertStations(List<Station> stations) async {
    var batch = db.batch();
    int count = 0;
    for (var station in stations) {
      List<Map<String, Object?>> list = await db.query('station',
          where: 'stationuuid = ?', whereArgs: [station.stationuuid], limit: 1);
      var jsValues = station.toJson();
      if (list.isEmpty) {
        batch.insert('station', jsValues);
      } else {
        var jsValues = station.toJson();
        jsValues.remove('id');
        batch.update('station', jsValues,
            where: 'id = ?', whereArgs: [list[0]['id']]);
      }
      count += 1;
      if (count >= kBatchSize) {
        print('commit batch: $count');
        await batch.apply(noResult: true, continueOnError: true);
        batch = db.batch();
        count = 0;
      }
    }

    await batch.apply(noResult: true, continueOnError: true);
  }

  Future<void> insertStation(Station station) async {
    return await db.transaction((txn) async {
      List<Map<String, Object?>> list = await txn.query('station',
          where: 'stationuuid = ?', whereArgs: [station.stationuuid], limit: 1);
      var jsValues = station.toJson();
      if (list.isEmpty) {
        txn.insert('station', jsValues);
      }
    });
  }

  Future<Map<String, dynamic>> insertRemoteSync(
      int startTime,
      List<FavGroup> groups,
      List<Recently> recently,
      List<Map<String, dynamic>> favorites) async {
    List<FavGroup> restGroups = List.empty(growable: true);
    List<FavGroup> newGroups = List.empty(growable: true);
    List<Recently> restRecently = List.empty(growable: true);
    List<Recently> newRecently = List.empty(growable: true);
    List<Map<String, dynamic>> restFavorites = List.empty(growable: true);
    List<Map<String, dynamic>> newFavorites = List.empty(growable: true);

    //非登录期间数据，全部合并 登录期间的数据，全量同步全合并，增量同步以服务器为准
    if (startTime > 0) {
      // 以数据库为准
      List<FavGroup>? dbFavGroups = await queryNotLoginGroups();
      if (dbFavGroups != null) {
        for (var group in dbFavGroups) {
          if (group.isDef == 1) {
            int index =
                groups.indexWhere((element) => element.isDef == group.isDef);
            if (index >= 0) {
              continue;
            }
          }
          int index =
              groups.indexWhere((element) => element.name == group.name);

          if (index >= 0) {
            if (groups[index].createTime > group.createTime) {
              newGroups.add(groups[index]);
              restGroups.add(groups[index]);
            } else {
              newGroups.add(group);
              restGroups.add(group);
            }
            continue;
          }

          newGroups.add(group);
        }
      } else {
        newGroups = groups;
      }

      List<Recently>? dbRecently = await queryNotLoginRecently();
      if (dbRecently != null) {
        restRecently = dbRecently;
        if (dbRecently.isNotEmpty) {
          newRecently.addAll(dbRecently);
        }
      } else {
        newRecently = recently;
      }

      List<Map<String, Object?>> dbFavorites = await db.rawQuery(
        '''select a.name as group_name, b.stationuuid, b.create_time from 
      fav_group a, favorite b where b.group_id = a.id and b.is_login = 0''',
      );

      if (favorites.isNotEmpty) {
        restFavorites = dbFavorites;
        newFavorites.addAll(dbFavorites);
      } else {
        newFavorites = favorites;
      }
    } else {
      // 全量同步 合并
      List<FavGroup>? dbFavGroups = await queryGroups();

      if (groups.isNotEmpty) {
        if (dbFavGroups != null) {
          for (var group in groups) {
            var index =
                dbFavGroups.indexWhere((element) => element.name == group.name);
            if (index == -1) {
              newGroups.add(group);
            }
          }
          for (var group in dbFavGroups) {
            var index =
                groups.indexWhere((element) => element.name == group.name);
            if (index == -1) {
              restGroups.add(group);
            }
          }
        } else {
          newGroups = groups;
        }
      } else {
        if (dbFavGroups != null) {
          restGroups = dbFavGroups;
        }
      }

      List<Recently> dbRecently = await queryRecently();

      if (recently.isNotEmpty) {
        if (dbRecently.isNotEmpty) {
          for (var r in recently) {
            var index = dbRecently.indexWhere((rc) =>
                rc.stationuuid == r.stationuuid && r.startTime == rc.startTime);
            if (index == -1) {
              newRecently.add(r);
            }
          }
          for (var r in dbRecently) {
            var index = recently.indexWhere((rc) =>
                rc.stationuuid == r.stationuuid && r.startTime == rc.startTime);
            if (index == -1) {
              restRecently.add(r);
            }
          }
        } else {
          newGroups = groups;
        }
      } else {
        restRecently = dbRecently;
      }

      List<Map<String, Object?>> dbFavorites = await db.rawQuery(
        '''select a.name as group_name, b.stationuuid, b.create_time from 
      fav_group a, favorite b where b.group_id = a.id''',
      );

      if (favorites.isNotEmpty) {
        if (dbFavorites.isNotEmpty) {
          for (var fv in favorites) {
            var index = dbFavorites.indexWhere((element) =>
                element['group_name'] == fv['group_name'] &&
                element['stationuuid'] == fv['stationuuid']);
            if (index == -1) {
              newFavorites.add(fv);
            }
          }
          for (var fv in dbFavorites) {
            var index = favorites.indexWhere((element) =>
                element['group_name'] == fv['group_name'] &&
                element['stationuuid'] == fv['stationuuid']);
            if (index == -1) {
              restFavorites.add(fv);
            }
          }
        } else {
          newFavorites = favorites;
        }
      } else {
        if (dbFavorites.isNotEmpty) {
          restFavorites = dbFavorites;
        }
      }
    }

    await db.transaction((txn) async {
      await txn.delete('fav_group');
      for (var group in newGroups) {
        var map = group.toJson();
        map['is_login'] = 1;
        await txn.insert('fav_group', map);
      }

      await txn.delete('recently');
      for (var recently in newRecently) {
        var map = recently.toJson();
        map['is_login'] = 1;
        await txn.insert('recently', map);
      }

      await txn.delete('favorite');
      for (var favorite in newFavorites) {
        var defFavGroupList = await txn.query('fav_group',
            where: 'name = ?', whereArgs: [favorite['group_name']]);
        if (defFavGroupList.isNotEmpty) {
          var defFavGroup = defFavGroupList[0];
          Map<String, Object?> values = {
            'stationuuid': favorite['stationuuid'],
            'group_id': defFavGroup['id'],
            'create_time': favorite['create_time'],
            'is_login': 1
          };
          await txn.insert('favorite', values);
        }
      }
    });

    Map<String, dynamic> map = HashMap();
    map['groups'] = restGroups;
    map['recently'] = restRecently;
    map['favorites'] = restFavorites;

    return map;
  }
}
