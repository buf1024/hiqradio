import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
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

  void setAuthToken(String token) async {
    if (!isInit) {
      await initDio();
    }

    var headers = dio.options.headers;

    token = 'Bearer $token';
    headers['Authorization'] = token;
    dio.options.headers = headers;
  }

  Future<void> initDio() async {
    var host = 'https://toyent.com';
    if (kDebugMode) {
      host = 'http://127.0.0.1:4000';
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

    print('data=${jsonEncode(param)}');

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
      {String? avatar, String? passwd, String? userName}) async {
    String url = '/user/modify';

    Map<String, dynamic> param = HashMap();
    if (userName != null) {
      param['user_name'] = 'userName';
    }
    if (avatar != null) {
      param['avatar_path'] = avatar;
    }
    if (passwd != null) {
      param['password'] = passwd;
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
}
