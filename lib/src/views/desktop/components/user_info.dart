import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/repository/userapi/userapi.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

enum ShowType { login, reward, register, userinfo, none }

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  OverlayEntry? userOverlay;

  bool isInit = false;

  Uint8List avatarData = Uint8List(0);

  int avatarChg = -1;

  UserApi userApi = RadioRepository.instance.userApi;

  @override
  void initState() {
    super.initState();

    getUserAvatar(0);
  }

  void getUserAvatar(int chgTag) async {
    if (chgTag != avatarChg) {
      String? avatar = await context.read<AppCubit>().getUserAvatar();
      setState(() {
        if (avatar != null) {
          avatarData = base64Decode(avatar);
        }
        avatarChg = chgTag;
      });
    }
  }

  void initUserInfo() async {
    if (mounted && !isInit) {
      isInit = true;

      var data = await userApi.userInfo();

      if (data['error'] == 0) {
        context.read<AppCubit>().setUserLogin(true,
            email: data['email'], userName: data['user_name']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin =
        context.select<AppCubit, bool>((value) => value.state.isLogin);

    Color dividerColor = Theme.of(context).dividerColor;

    ShowType type = isLogin ? ShowType.userinfo : ShowType.login;

    int avatarChgTag =
        context.select<AppCubit, int>((value) => value.state.avatarChgTag);

    getUserAvatar(avatarChgTag);
    initUserInfo();

    return InkClick(
        onTap: () => _onShowUser(ShowType.none, type),
        child: isLogin
            ? Container(
                width: 42.0,
                height: 42.0,
                margin: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: avatarData.isEmpty
                      ? const Image(
                          image: AssetImage('assets/images/login.png'),
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          avatarData,
                          fit: BoxFit.cover,
                        ),
                ),
              )
            : Container(
                width: 42.0,
                height: 42.0,
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    border: Border.all(color: dividerColor),
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(
                  IconFont.notsignin,
                  size: 26.0,
                ),
              ));
  }

  void _onCloseContent(ShowType from, ShowType next) {
    _closeShowUser();
    if (ShowType.none != next) {
      _onShowUser(from, next);
    }
  }

  Widget? _getContent(ShowType from, ShowType type) {
    switch (type) {
      case ShowType.login:
        return _UserLogin(
          from: from,
          onClose: (from, next) => _onCloseContent(from, next),
        );
      case ShowType.reward:
        return _UserReward(
          from: from,
          onClose: (from, next) => _onCloseContent(from, next),
        );
      case ShowType.register:
        return _UserRegister(
          from: from,
          onClose: (from, next) => _onCloseContent(from, next),
        );
      case ShowType.userinfo:
        return _UserDetail(
          from: from,
          onClose: (from, next) => _onCloseContent(from, next),
        );
      case ShowType.none:
        return null;
    }
  }

  void _onShowUser(ShowType from, ShowType type) {
    double width = type == ShowType.userinfo ? 600.0 : 300.0;
    double posLeft = (MediaQuery.of(context).size.width - width) / 2;
    double height = MediaQuery.of(context).size.height - kTitleBarHeight - 4;

    userOverlay ??= OverlayEntry(
      opaque: false,
      builder: (context) {
        // 猥琐发育
        return Stack(
          fit: StackFit.loose,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 0),
              // padding: const EdgeInsets.only(top: kTitleBarHeight),
              child: ModalBarrier(
                onDismiss: () => _closeShowUser(),
              ),
            ),
            Positioned(
              top: kTitleBarHeight + 4,
              left: posLeft,
              width: width,
              height: height,
              child: StatefulBuilder(builder: (context, setState) {
                return Material(
                  color: Colors.black.withOpacity(0),
                  child: Dialog(
                    alignment: Alignment.center,
                    insetPadding: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 0, left: 0),
                    elevation: 2.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Container(
                        width: width,
                        height: height,
                        child: Column(
                          children: [
                            Container(
                              height: kTitleBarHeight,
                              width: width,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 8.0),
                                    child: InkClick(
                                      onTap: () {
                                        _closeShowUser();
                                      },
                                      child: const Icon(
                                        IconFont.close,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: height - kTitleBarHeight,
                              width: width,
                              child: _getContent(from, type),
                            ),
                          ],
                        )),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(userOverlay!);
  }

  void _closeShowUser() {
    if (userOverlay != null) {
      userOverlay!.remove();
      userOverlay = null;
    }
  }
}

class _UserLogin extends StatefulWidget {
  final Function(ShowType, ShowType) onClose;
  final ShowType from;
  const _UserLogin({required this.onClose, required this.from});

  @override
  State<_UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<_UserLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  UserApi userApi = RadioRepository.instance.userApi;

  bool captchaLoading = false;
  bool signinLoading = false;

  Uint8List captcha = Uint8List(0);

  bool openFlag = true;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwdController.dispose();
    codeController.dispose();
  }

  void initLogin() async {
    if (mounted && !isInit) {
      isInit = true;

      emailController.text =
          context.select<AppCubit, String>((value) => value.state.userEmail);
      requestCaptcha();
    }
  }

  void requestCaptcha() async {
    if (captchaLoading) {
      return;
    }
    setState(() {
      captchaLoading = true;
      captcha = Uint8List(0);
    });

    var data = await userApi.captcha();

    setState(() {
      captchaLoading = false;
      if (data['error'] == 0) {
        captcha = base64Decode(data["captcha"]);
      }
    });
  }

  void requestSignin(String email, String passwd, String captcha) async {
    if (signinLoading) {
      return;
    }
    setState(() {
      signinLoading = true;
    });

    var data = await userApi.userSignin(
        email: email, passwd: passwd, captcha: captcha, flag: openFlag);

    setState(() {
      signinLoading = false;
    });
    String toastMsg = '';
    if (data['error'] == 0) {
      String token = data['token'];
      String? userName;
      {
        var data = await userApi.userInfo();
        if (data['error'] == 0) {
          userName = data['user_name'];
        }
      }
      context
          .read<AppCubit>()
          .setUserLogin(true, token: token, email: email, userName: userName);

      widget.onClose(widget.from, ShowType.none);
    } else {
      requestCaptcha();
      toastMsg = '登录失败: ${data['message']}';
    }

    if (toastMsg.isNotEmpty) {
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    initLogin();
    return Column(
      children: [
        const Spacer(),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text("邮箱:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, emailController, "注册的邮箱"),
            )
          ],
        ),
        SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.centerRight,
              child: Text("密码:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, passwdController, "登录密码",
                  obscureText: true),
            )
          ],
        ),
        SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.centerRight,
              child: Text("验证码:"),
            ),
            Container(
              height: 26,
              width: 112.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _textField(context, codeController, "验证码"),
            ),
            InkClick(
              onTap: () => requestCaptcha(),
              child: Container(
                height: 26,
                width: 60.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: captchaLoading
                      ? Container(
                          height: 26.0,
                          width: 26.0,
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        )
                      : (captcha.isEmpty
                          ? const Text(
                              '刷新',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13.0, fontStyle: FontStyle.italic),
                            )
                          : Image.memory(captcha)),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.centerRight,
              child: Text("自动注册:"),
            ),
            Checkbox(
              splashRadius: 0,
              checkColor: Theme.of(context).textTheme.bodyMedium!.color!,
              focusColor: Colors.black.withOpacity(0),
              hoverColor: Colors.black.withOpacity(0),
              activeColor: Colors.black.withOpacity(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              side: MaterialStateBorderSide.resolveWith(
                (states) => BorderSide(
                  width: 1.0,
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
              value: openFlag,
              onChanged: (value) {
                if (value != null && value != openFlag) {
                  setState(() {
                    openFlag = value;
                  });
                }
              },
            ),
            Text(
              '使用其他app账号登录',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
            )
          ],
        ),
        const SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            const SizedBox(
              height: 26,
              width: 130,
            ),
            Container(
              height: 26,
              width: 60.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: MaterialButton(
                color: Colors.deepPurpleAccent,
                onPressed: () {
                  widget.onClose!(widget.from, ShowType.reward);
                },
                child: Text(
                  '注册',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            Container(
              height: 26,
              width: 60.0,
              child: MaterialButton(
                color: Colors.redAccent,
                onPressed: () {
                  String toastMsg = '';
                  if (emailController.text.isEmpty) {
                    toastMsg += 'email 为空\n';
                  }
                  if (emailController.text.isNotEmpty &&
                      !_isEmailValid(emailController.text)) {
                    toastMsg += 'email 格式不正确\n';
                  }
                  if (passwdController.text.isEmpty) {
                    toastMsg += '密码为空\n';
                  }
                  if (codeController.text.isEmpty) {
                    toastMsg += '验证码为空\n';
                  }
                  if (toastMsg.isNotEmpty) {
                    showToast(toastMsg,
                        position: const ToastPosition(
                          align: Alignment.bottomCenter,
                        ),
                        duration: const Duration(seconds: 5));
                  } else {
                    requestSignin(emailController.text, passwdController.text,
                        codeController.text);
                  }
                },
                child: Text(
                  '登录',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            )
          ],
        ),
        Spacer(),
      ],
    );
  }
}

bool _isEmailValid(String email) {
  return RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);
}

Widget _textField(
    BuildContext context, TextEditingController controller, String hintText,
    {bool obscureText = false, bool readOnly = false}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    autocorrect: false,
    obscuringCharacter: '*',
    obscureText: obscureText,
    cursorWidth: 1.0,
    showCursor: !readOnly,
    cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
    style: const TextStyle(fontSize: 14.0),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
      fillColor: Colors.grey.withOpacity(0.2),
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
          borderRadius: BorderRadius.circular(5.0)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.0)),
          borderRadius: BorderRadius.circular(5.0)),
    ),
    onSubmitted: (value) {
      // context
      //     .read<FavoriteCubit>()
      //     .updateGroup(value, group.desc == null ? '' : group.desc!);
    },
    onTap: () async {},
  );
}

class _UserReward extends StatefulWidget {
  final Function(ShowType, ShowType) onClose;
  final ShowType from;
  const _UserReward({required this.onClose, required this.from});

  @override
  State<_UserReward> createState() => _UserRewardState();
}

class _UserRewardState extends State<_UserReward> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset('assets/images/reward_qrcode.png'),
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text('赞赏'),
              Text('是为了维持服务器的正常开销'),
              Text('1分也是爱'),
              Text('当然也是可以跳过的'),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Spacer(),
              InkClick(
                onTap: () {
                  ShowType next = ShowType.register;
                  if (ShowType.none != widget.from) {
                    next = widget.from;
                  }
                  widget.onClose(widget.from, next);
                },
                child: const Text(
                  '跳过',
                  style: TextStyle(fontSize: 12.0, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _UserRegister extends StatefulWidget {
  final Function(ShowType, ShowType) onClose;
  final ShowType from;
  const _UserRegister({required this.onClose, required this.from});

  @override
  State<_UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<_UserRegister> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController passwd2Controller = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();

  UserApi userApi = RadioRepository.instance.userApi;

  bool captchaLoading = false;
  Uint8List captcha = Uint8List(0);

  bool verifyCodeSending = false;
  bool verifyCodeSended = false;

  bool signinLoading = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwdController.dispose();
    passwd2Controller.dispose();
    codeController.dispose();
    verifyCodeController.dispose();
  }

  void _init() async {
    requestCaptcha();
  }

  void requestCaptcha() async {
    if (captchaLoading) {
      return;
    }
    setState(() {
      captchaLoading = true;
      captcha = Uint8List(0);
    });

    var data = await userApi.captcha();

    setState(() {
      captchaLoading = false;
      if (data['error'] == 0) {
        captcha = base64Decode(data["captcha"]);
      }
    });
  }

  void requestSendEmailCode(String email, String captcha) async {
    if (verifyCodeSending) {
      return;
    }
    setState(() {
      verifyCodeSending = true;
    });

    var data = await userApi.sendEmailCode(email: email, captcha: captcha);
    setState(() {
      verifyCodeSending = false;
    });
    debugPrint('data=$data');
    if (data['error'] == 0) {
      setState(() {
        verifyCodeSended = true;
      });
    } else {
      String toastMsg = '邮箱验证码请求失败: ${data['error']}, ${data['message']}';
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  void requestSignup(
      String email, String passwd, String captcha, String verifyCode) async {
    if (signinLoading) {
      return;
    }
    setState(() {
      signinLoading = true;
    });

    var data = await userApi.userSignup(
        email: email, passwd: passwd, captcha: captcha, verifyCode: verifyCode);
    setState(() {
      signinLoading = false;
    });
    if (data['error'] == 0) {
      String toastMsg = '用户注册成功，请登录！';
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
      widget.onClose(widget.from, ShowType.login);
    } else {
      String toastMsg = '用户注册失败: ${data['error']}, ${data['message']}';
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text("邮箱:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, emailController, "注册的邮箱"),
            )
          ],
        ),
        const SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.centerRight,
              child: Text("验证码:"),
            ),
            Container(
              height: 26,
              width: 112.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _textField(context, codeController, "验证码"),
            ),
            InkClick(
              onTap: () => requestCaptcha(),
              child: Container(
                height: 26,
                width: 60.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: captchaLoading
                      ? Container(
                          height: 26.0,
                          width: 26.0,
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        )
                      : (captcha.isEmpty
                          ? const Text(
                              '刷新',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13.0, fontStyle: FontStyle.italic),
                            )
                          : Image.memory(captcha)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 180,
              padding: const EdgeInsets.only(right: 8.0),
            ),
            Container(
              height: 26,
              width: 80.0,
              child: MaterialButton(
                color: Colors.redAccent,
                onPressed: () {
                  // widget.onClose!(ShowType.none);
                  if (!verifyCodeSending) {
                    String email = emailController.text;
                    if (email.isNotEmpty && _isEmailValid(email)) {
                      requestSendEmailCode(email, codeController.text);
                    } else {
                      String toastMsg = '邮箱不合法';
                      showToast(toastMsg,
                          position: const ToastPosition(
                            align: Alignment.bottomCenter,
                          ),
                          duration: const Duration(seconds: 5));
                    }
                  }
                },
                child: verifyCodeSending
                    ? Container(
                        height: 26.0,
                        width: 26.0,
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                      )
                    : Text(
                        '发送校验码',
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
              ),
            )
          ],
        ),
        verifyCodeSended
            ? Column(
                children: [
                  const SizedBox(
                    height: 6.0,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 26,
                        width: 80,
                        padding: const EdgeInsets.only(right: 8.0),
                        alignment: Alignment.centerRight,
                        child: Text("校验码:"),
                      ),
                      Container(
                        height: 26,
                        width: 180.0,
                        child: _textField(
                          context,
                          verifyCodeController,
                          "邮箱校验码",
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 26,
                        width: 80,
                        padding: const EdgeInsets.only(right: 8.0),
                        alignment: Alignment.centerRight,
                        child: Text("密码:"),
                      ),
                      Container(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwdController, "登录密码",
                            obscureText: true),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 26,
                        width: 80,
                        padding: const EdgeInsets.only(right: 8.0),
                        alignment: Alignment.centerRight,
                        child: Text("重输密码:"),
                      ),
                      Container(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwd2Controller, "重输登录密码",
                            obscureText: true),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 26,
                        width: 200,
                        padding: const EdgeInsets.only(right: 8.0),
                      ),
                      Container(
                        height: 26,
                        width: 60.0,
                        margin: const EdgeInsets.only(right: 8.0),
                        child: MaterialButton(
                          color: Colors.deepPurpleAccent,
                          onPressed: () {
                            if (!signinLoading) {
                              String toastMsg = '';
                              if (emailController.text.isEmpty ||
                                  !_isEmailValid(emailController.text)) {
                                toastMsg += '邮箱地址为空或者无效\n';
                              }
                              if (codeController.text.isEmpty) {
                                toastMsg += '验证码为空\n';
                              }
                              if (verifyCodeController.text.isEmpty) {
                                toastMsg += '邮箱校验码为空\n';
                              }
                              if (passwdController.text.isEmpty ||
                                  passwd2Controller.text.isEmpty) {
                                toastMsg += '密码或重输密码框为空\n';
                              }
                              if (passwdController.text !=
                                  passwd2Controller.text) {
                                toastMsg += '两次输入的密码不一致\n';
                              }
                              if (passwdController.text.length < 6) {
                                toastMsg += '密码长度必须大于等于6\n';
                              }

                              if (toastMsg.isNotEmpty) {
                                showToast(toastMsg,
                                    position: const ToastPosition(
                                      align: Alignment.bottomCenter,
                                    ),
                                    duration: const Duration(seconds: 5));
                              } else {
                                requestSignup(
                                    emailController.text,
                                    passwdController.text,
                                    codeController.text,
                                    verifyCodeController.text);
                              }
                            }
                          },
                          child: signinLoading
                              ? Container(
                                  height: 26.0,
                                  width: 26.0,
                                  padding: const EdgeInsets.all(4.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!,
                                  ),
                                )
                              : Text(
                                  '注册',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Container(),
        const Spacer(),
      ],
    );
  }
}

class _UserDetail extends StatefulWidget {
  final Function(ShowType, ShowType) onClose;
  final ShowType from;
  const _UserDetail({required this.onClose, required this.from});

  @override
  State<_UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<_UserDetail> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController passwd2Controller = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  UserApi userApi = RadioRepository.instance.userApi;

  Uint8List captcha = Uint8List(0);

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> userProducts = [];

  bool isModifying = false;
  bool isRequestModifying = false;
  bool isRequestSignouting = false;
  bool isRequestAvatarModifying = false;

  Uint8List avatarData = Uint8List(0);

  bool isInit = false;

  int avatarChg = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwdController.dispose();
    passwd2Controller.dispose();
    userNameController.dispose();
  }

  void initDetail() async {
    if (mounted && !isInit) {
      isInit = true;

      userNameController.text =
          context.select<AppCubit, String>((value) => value.state.userName);
      emailController.text =
          context.select<AppCubit, String>((value) => value.state.userEmail);

      var data = await userApi.userProducts();
      if (data['error'] == 0) {
        for (var element in (data['products'] as List)) {
          products.add(element);
        }

        data = await userApi.userOpenProducts();
        if (data['error'] == 0) {
          for (var element in (data['products'] as List)) {
            userProducts.add(element);
          }
        }
        setState(() {});
      }
      // Map<String, dynamic> aa = HashMap();

      // products.add(aa);
    }
  }

  void requestModify() async {
    setState(() {
      isRequestModifying = true;
    });

    var data = await userApi.userModify(
        userName: userNameController.text, passwd: passwdController.text);

    setState(() {
      isRequestModifying = false;
    });

    if (data['error'] == 0) {
      context.read<AppCubit>().setUserLogin(true,
          email: emailController.text, userName: userNameController.text);

      showToast('修改用户信息成功',
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    } else {
      showToast('修改用户信息失败: ${data['error']}',
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  void requestSignout() async {
    setState(() {
      isRequestSignouting = true;
    });

    var data = await userApi.userSignout();

    setState(() {
      isRequestSignouting = false;
    });

    widget.onClose(widget.from, ShowType.none);
    context.read<AppCubit>().setUserLogin(false,
        email: emailController.text, userName: userNameController.text);
  }

  void requestModifyAvatar(final File file) async {
    setState(() {
      isRequestAvatarModifying = true;
    });

    String toastMsg = '';
    var data = await userApi.userUpload(file: file);
    if (data['error'] == 0) {
      String avatarPath = data['avatar_path'];
      data = await userApi.userModify(avatar: avatarPath);

      if (data['error'] == 0) {
        avatarData = await file.readAsBytes();
        var avatar = base64Encode(avatarData);

        context.read<AppCubit>().setAvatar(avatar);
      } else {
        '更改头像失败: ${data['error']}';
      }
    } else {
      toastMsg = '上传头像失败: ${data['error']}';
    }
    setState(() {
      isRequestAvatarModifying = false;
    });
    if (toastMsg.isNotEmpty) {
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  void getUserAvatar(int chgTag) async {
    if (chgTag != avatarChg) {
      String? avatar = await context.read<AppCubit>().getUserAvatar();
      setState(() {
        if (avatar != null) {
          avatarData = base64Decode(avatar);
        }
        avatarChg = chgTag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int avatarChgTag =
        context.select<AppCubit, int>((value) => value.state.avatarChgTag);
    getUserAvatar(avatarChgTag);
    initDetail();

    return Column(
      children: [
        const SizedBox(
          height: 12.0,
        ),
        InkClick(
          onTap: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.image);

            if (result != null) {
              File file = File(result.files.single.path!);
              requestModifyAvatar(file);
            }
            await windowManager.orderFront();
          },
          child: Container(
            width: 80.0,
            height: 80.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: avatarData.isEmpty
                  ? const Image(
                      image: AssetImage('assets/images/login.png'),
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      avatarData,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
        Row(
          children: [
            const Spacer(),
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text("邮箱:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child:
                  _textField(context, emailController, "注册的邮箱", readOnly: true),
            ),
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text("用户名:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, userNameController, "用户名",
                  readOnly: !isModifying),
            ),
            const Spacer(),
          ],
        ),
        Column(
          children: [
            SizedBox(
              height: 6.0,
            ),
            Row(
              children: [
                const Spacer(),
                Container(
                  height: 26,
                  width: 80,
                  padding: const EdgeInsets.only(right: 8.0),
                  alignment: Alignment.centerRight,
                  child: Text("密码:"),
                ),
                Container(
                  height: 26,
                  width: 180.0,
                  child: _textField(context, passwdController, "登录密码",
                      obscureText: true, readOnly: !isModifying),
                ),
                Container(
                  height: 26,
                  width: 80,
                  padding: const EdgeInsets.only(right: 8.0),
                  alignment: Alignment.centerRight,
                  child: Text("重输密码:"),
                ),
                Container(
                  height: 26,
                  width: 180.0,
                  child: _textField(context, passwd2Controller, "重输登录密码",
                      obscureText: true, readOnly: !isModifying),
                ),
                const Spacer(),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 12.0,
        ),
        Row(
          children: [
            const SizedBox(
              height: 26,
              width: 120,
            ),
            Container(
              height: 26,
              child: MaterialButton(
                color: !isModifying ? Colors.blueAccent : Colors.redAccent,
                onPressed: () {
                  if (isModifying) {
                    String toastMsg = '';
                    if (userNameController.text.isEmpty) {
                      toastMsg += '用户名为空\n';
                    }
                    if (passwdController.text.isEmpty ||
                        passwd2Controller.text.isEmpty) {
                      toastMsg += '密码或重输密码框为空\n';
                    }
                    if (passwdController.text != passwd2Controller.text) {
                      toastMsg += '两次输入的密码不一致\n';
                    }
                    if (passwdController.text.length < 6) {
                      toastMsg += '密码长度必须大于等于6\n';
                    }

                    if (toastMsg.isNotEmpty) {
                      showToast(toastMsg,
                          position: const ToastPosition(
                            align: Alignment.bottomCenter,
                          ),
                          duration: const Duration(seconds: 5));
                    } else {
                      requestModify();
                    }
                  } else {
                    setState(() {
                      isModifying = true;
                    });
                  }
                },
                child: Text(
                  !isModifying ? '信息修改' : '修改',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            isModifying
                ? Container(
                    height: 26,
                    margin: const EdgeInsets.only(left: 10.0, right: 190),
                    child: MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        setState(() {
                          isModifying = !isModifying;
                        });
                      },
                      child: Text(
                        '取消修改',
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 280,
                  ),
            Container(
              height: 26,
              child: MaterialButton(
                color: Colors.redAccent,
                onPressed: () {
                  requestSignout();
                },
                child: isRequestSignouting
                    ? Container(
                        height: 26.0,
                        width: 26.0,
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                      )
                    : Text(
                        '退出',
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(
          height: 24.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 120,
              padding: const EdgeInsets.only(right: 8.0),
              alignment: Alignment.centerRight,
              child: Text(
                '程序注册信息:',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Expanded(
          child: _table(),
        )
      ],
    );
  }

  Widget _empty() {
    // bool isLoading =

    return const Center(
      child: Text(
        'No products',
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }

  bool isOpenProduct(String name) {
    bool isOpen = false;
    try {
      userProducts.firstWhere((element) => element['product'] == name);
      isOpen = true;
      // ignore: empty_catches
    } catch (e) {}
    return isOpen;
  }

  Widget _table() {
    // List<Pair<Station, Recently>> recentlys =
    //     context.select<RecentlyCubit, List<Pair<Station, Recently>>>(
    //         (value) => value.state.pagedRecently);

    // Station? playingStation = context.select<AppCubit, Station?>(
    //   (value) => value.state.playingStation,
    // );
    // bool isPlaying = context.select<AppCubit, bool>(
    //   (value) => value.state.isPlaying,
    // );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        dividerThickness:
            0, // this one will be ignored if [border] is set above
        bottomMargin: 10,
        // minWidth: 900,
        // sortColumnIndex: 4,
        sortAscending: true,
        sortArrowIcon: Icons.keyboard_arrow_up, // custom arrow
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        dataRowHeight: 35.0,
        headingRowHeight: 35.0,
        headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.grey.withOpacity(0.1)),
        columns: [
          DataColumn2(label: Text('名称'), fixedWidth: 60.0),
          DataColumn2(label: Text('描述')),
          DataColumn2(label: Text('开通时间'), fixedWidth: 150.0),
          DataColumn2(label: Text('操作'), fixedWidth: 50.0),
        ],
        empty: _empty(),

        rows: products.asMap().entries.map(
          (e) {
            int index = e.key;
            Map<String, dynamic> map = e.value;

            String product = map['product'];
            String desc = map['desc'];
            String time = DateFormat("yyyy-MM-dd HH:mm:ss").format(
                DateTime.fromMillisecondsSinceEpoch(map['update_time']));

            bool isOpen = isOpenProduct(product);

            return DataRow2(
              // selected: isSelected,
              color: index.isEven
                  ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                  : null,
              onSecondaryTapDown: (details) {},
              onDoubleTap: () {},
              cells: [
                DataCell(
                  Text(product),
                ),
                DataCell(
                  Text(
                    desc,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    time,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                      color: isOpen ? Colors.black45 : Colors.redAccent,
                      borderRadius: BorderRadius.circular(4.0)),
                  child: InkClick(
                    onTap: () {
                      if (!isOpen) {
                        widget.onClose(ShowType.userinfo, ShowType.reward);
                      }
                    },
                    child: Text(
                      isOpen ? '已注册' : '注册',
                      style: const TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                )),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}
