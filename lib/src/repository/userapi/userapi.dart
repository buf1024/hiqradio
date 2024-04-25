import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


const kErrSuccess = 0;
const kErrProductNotOpen = 888;

class UserApi {
  String userAgent = 'hiqradio/1.0';
  String host = '';
  Dio dio = Dio();
  bool isInit = false;

  static final UserApi _instance = UserApi._();

  static Future<UserApi> create() async {
    UserApi api = UserApi._instance;
    if (!api.isInit) {
      await api.initDio();
    }
    return api;
  }

  UserApi._();

  Future<void> initDio() async {
    var host = 'https://toyent.com';
    if (kDebugMode) {
      host = 'http://127.0.0.1:4000';
    }
    var baseUrl = '$host/api';

    dio.options.baseUrl = baseUrl;
    Map<String, dynamic> headers = HashMap();
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json';

    dio.options.headers = headers;
    dio.options.responseType = ResponseType.json;
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
    param["email"] = email;
    param["captcha"] = captcha;

    Response response = await dio.post(url, data: jsonEncode(param));

    return response.data;
  }
}
