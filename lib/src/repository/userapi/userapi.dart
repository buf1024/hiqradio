import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:hiqradio/src/models/fav_group.dart';
import 'package:hiqradio/src/models/recently.dart';
import 'package:path_provider/path_provider.dart';

const kErrSuccess = 0;
const kErrProductNotOpen = 888;

const kProduct = 'hiqradio';

class UserApi {
  String userAgent = 'hiqradio/1.0';
  String host = '';
  Dio dio = Dio();
  bool isInit = false;

  late CookieJar cookieJar;

  static final UserApi _instance = UserApi._();

  static Future<UserApi> create() async {
    debugPrint('init userapi..');
    UserApi api = UserApi._instance;
    if (!api.isInit) {
      await api.initDio();
      debugPrint('userapi initd');
    }
    return api;
  }

  UserApi._();

  Future<void> setAuthToken(String token) async {
    if (!isInit) {
      await initDio();
    }
    var headers = dio.options.headers;

    token = 'Bearer $token';
    headers['Authorization'] = token;
    dio.options.headers = headers;
  }

  String? getAuthToken() {
    var headers = dio.options.headers;
    return headers['Authorization'];
  }

  Future<void> initDio() async {
    var host = 'https://toyent.com';
    if (kDebugMode) {
      host = 'http://10.0.0.18:4000';
    }
    var baseUrl = '$host/api';

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("$appDocPath/.cookies/"),
    );

    dio.options.baseUrl = baseUrl;
    Map<String, dynamic> headers = HashMap();
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json';

    dio.options.headers = headers;
    dio.options.responseType = ResponseType.json;

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<Map<String, dynamic>> captcha() async {
    String url = '/common/captcha';
    Response response = await dio.get(url);

    return response.data;
  }

  Future<Map<String, dynamic>> sendEmailCode(
      {required String email, required String captcha}) async {
    String url = '/common/send_email_code';

    Map<String, dynamic> param = HashMap();
    param['email'] = email;
    param['captcha'] = captcha;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userSignup(
      {required String email,
      required String passwd,
      required String captcha,
      required String verifyCode}) async {
    String url = '/user/signup';

    Map<String, dynamic> param = HashMap();
    param['product'] = kProduct;

    param['email'] = email;
    param['passwd'] = passwd;
    param['captcha'] = captcha;
    param['code'] = verifyCode;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userIsLogin() async {
    String url = '/user/is_login';

    Map<String, dynamic> param = HashMap();
    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userSignin(
      {required String email,
      required String passwd,
      required String captcha,
      required bool flag}) async {
    String url = '/user/signin';

    Map<String, dynamic> param = HashMap();
    param['product'] = kProduct;
    param['email'] = email;
    param['passwd'] = passwd;
    param['captcha'] = captcha;
    param['product_open_flag'] = flag;

    Response response = await dio.post(url, data: jsonEncode(param));
    if (response.data['error'] == 0) {
      String token = response.data['token'];

      setAuthToken(token);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> userSignout() async {
    String url = '/user/signout';

    Map<String, dynamic> param = HashMap();

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userInfo() async {
    String url = '/user/user_info';

    Map<String, dynamic> param = HashMap();

    var headers = dio.options.headers;
    headers['Connection'] = 'keep-alive';
    Response response = await dio.post(url, data: jsonEncode(param));
    headers.remove('Connection');
    return response.data;
  }

  Future<Map<String, dynamic>> userUpload({required File file}) async {
    String url = '/user/upload';

    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    Response response = await dio.post(url, data: formData);

    return response.data;
  }

  Future<Map<String, dynamic>> userModify(
      {String? avatar,
      String? passwd,
      String? newPassword,
      String? userName}) async {
    String url = '/user/modify';

    Map<String, dynamic> param = HashMap();
    if (userName != null) {
      param['user_name'] = userName;
    }
    if (avatar != null) {
      param['avatar_path'] = avatar;
    }
    if (passwd != null) {
      param['password'] = passwd;
    }
    if (newPassword != null) {
      param['new_password'] = newPassword;
    }

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userOpenProducts() async {
    String url = '/user/user_products';

    Map<String, dynamic> param = HashMap();

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userProducts() async {
    String url = '/user/products';

    Map<String, dynamic> param = HashMap();

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userOpenProduct(
      {required String product}) async {
    String url = '/user/open_product';

    Map<String, dynamic> param = HashMap();
    param['product'] = product;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> userResetPasswd(
      {required String email,
      required String passwd,
      required String captcha,
      required String verifyCode}) async {
    String url = '/user/reset_passwd';

    Map<String, dynamic> param = HashMap();
    param['email'] = email;
    param['passwd'] = passwd;
    param['captcha'] = captcha;
    param['code'] = verifyCode;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioSync(int startTime) async {
    String url = '/hiqradio/sync';

    Map<String, dynamic> param = HashMap();
    param['start_time'] = startTime;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioGroupNew(List<FavGroup> favGroups) async {
    String url = '/hiqradio/group_new';

    List<Map<String, dynamic>> groupsParam = List.empty(growable: true);
    for (var group in favGroups) {
      Map<String, dynamic> param = HashMap();

      param['name'] = group.name;
      param['desc'] = group.desc ?? '';
      param['is_def'] = group.isDef;
      param['create_time'] = group.createTime;

      groupsParam.add(param);
    }

    Map<String, dynamic> param = HashMap();

    param['new_group'] = groupsParam;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioGroupModify(
      String oldName, String name, String desc) async {
    String url = '/hiqradio/group_modify';

    Map<String, dynamic> param = HashMap();

    param['old_name'] = oldName;
    param['name'] = name;
    param['desc'] = desc;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioGroupDelete(
      List<FavGroup> favGroups) async {
    String url = '/hiqradio/group_delete';

    List<String> groupsParam = List.empty(growable: true);
    for (var group in favGroups) {
      groupsParam.add(group.name);
    }

    Map<String, dynamic> param = HashMap();

    param['groups'] = groupsParam;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioRecentlyNew(List<Recently> recently) async {
    String url = '/hiqradio/recently_new';

    List<Map<String, dynamic>> recentlyParam = List.empty(growable: true);
    for (var r in recently) {
      Map<String, dynamic> param = HashMap();

      param['stationuuid'] = r.stationuuid;
      param['start_time'] = r.startTime;
      param['end_time'] = r.endTime;

      recentlyParam.add(param);
    }

    Map<String, dynamic> param = HashMap();

    param['new_recently'] = recentlyParam;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioRecentlyModify(Recently recently) async {
    String url = '/hiqradio/recently_modify';

    Map<String, dynamic> param = HashMap();

    param['stationuuid'] = recently.stationuuid;
    param['start_time'] = recently.startTime;
    param['end_time'] = recently.endTime;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioRecentlyClear() async {
    String url = '/hiqradio/recently_clear';

    Map<String, dynamic> param = HashMap();

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioFavoriteNew(
      List<Map<String, dynamic>> favorites) async {
    String url = '/hiqradio/favorite_new';

    List<Map<String, dynamic>> favoriteParam = List.empty(growable: true);
    for (var r in favorites) {
      favoriteParam.add(r);
    }

    Map<String, dynamic> param = HashMap();

    param['new_favorite'] = favoriteParam;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }

  Future<Map<String, dynamic>> radioFavoriteDelete(
      List<String> stations, List<String> groups) async {
    String url = '/hiqradio/favorite_delete';

    Map<String, dynamic> param = HashMap();

    param['favorites'] = stations;
    param['group_names'] = groups;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }
}
