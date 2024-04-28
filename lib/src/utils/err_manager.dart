import 'dart:collection';

import 'package:flutter/material.dart';

class ErrorManager {
  bool isInit = false;
  ErrorManager._();
  final Map<int, String> _cnMap = HashMap();
  final Map<int, String> _enMap = HashMap();

  static final ErrorManager instance = ErrorManager._();

  void initError() {
    if (!isInit) {
      _cnMap[401] = '同邮箱用户已存在';
      _cnMap[402] = '验证码错误';
      _cnMap[403] = '用户不存在';
      _cnMap[404] = '用户密码错误';
      _cnMap[405] = '操作过于频繁';
      _cnMap[406] = '产品不存在';
      _cnMap[407] = '发送邮件错误';
      _cnMap[408] = '未登录';
      _cnMap[409] = '密码长度过短(必须大于等于6)';
      _cnMap[410] = '邮箱不一致';
      _cnMap[411] = '邮箱格式错误';
      _cnMap[412] = '邮箱校验码错误';
      _cnMap[500] = '内部错误';
      _cnMap[501] = '未知错误';
      _cnMap[502] = '数据库异常';
      _cnMap[900] = '请求协议不完整';
      _cnMap[888] = '用户尚未开通该产品';

      _enMap[401] = 'Account exists';
      _enMap[402] = 'Captcha incorrect';
      _enMap[403] = 'Account not exists';
      _enMap[404] = 'Password Error';
      _enMap[405] = 'Operation too quickly';
      _enMap[406] = 'Product not exists';
      _enMap[407] = 'Send email error';
      _enMap[408] = 'Not signin';
      _enMap[409] = 'Password too short(at least 6)';
      _enMap[410] = 'Email different from previous';
      _enMap[411] = 'Email incorrect';
      _enMap[412] = 'Email verify code incorrect';
      _enMap[500] = 'Internal error';
      _enMap[501] = 'Unknown error';
      _enMap[502] = 'Database error';
      _enMap[900] = 'Protocol error';
      _enMap[888] = 'Product not register';

      isInit = true;
    }
  }

  String error(int code, String locale) {
    debugPrint(locale);
    if (locale == 'en') {
      if (_enMap.containsKey(code)) {
        return '${_enMap[code]}';
      }
    } else if (locale == 'zh') {
      if (_cnMap.containsKey(code)) {
        return '${_cnMap[code]}';
      }
    }

    return 'Error: $code';
  }
}
