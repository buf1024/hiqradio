import 'dart:convert';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';
import 'package:hiqradio/src/blocs/favorite_cubit.dart';
import 'package:hiqradio/src/blocs/recently_cubit.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/repository/userapi/userapi.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ShowType { login, reward, register, userinfo, resetPass, none }

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  OverlayEntry? userOverlay;

  bool isInit = false;
  bool isTestSigning = false;

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

      if (avatar != null && avatar.isNotEmpty) {
        avatarData = base64Decode(avatar);
      } else {
        avatarData = Uint8List(0);
      }
      avatarChg = chgTag;
    }
  }

  void initUserInfo() async {
    if (mounted && !isInit) {
      isInit = true;

      String? token = userApi.getAuthToken();

      if (token != null && token.isNotEmpty) {
        setState(() {
          isTestSigning = true;
        });

        try {
          var data = await userApi.userIsLogin();
          if (data['error'] == 0) {
            data = await userApi.userInfo();

            if (data['error'] == 0) {
              String? avatar = data['avatar'];
              if (avatar != null) {
                context.read<AppCubit>().setAvatar(avatar);
              } else {
                context.read<AppCubit>().setAvatar('');
              }

              context.read<AppCubit>().setUserLogin(true,
                  email: data['email'], userName: data['user_name']);
              context.read<RecentlyCubit>().setUserLogin(true);
              context.read<FavoriteCubit>().setUserLogin(true);

              context.read<AppCubit>().startSync();
            }
          }
        } catch (_) {}

        setState(() {
          isTestSigning = false;
        });
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
            : Stack(
                children: [
                  Container(
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
                  ),
                  if (isTestSigning)
                    Center(
                      child: Container(
                        height: 42.0,
                        width: 42.0,
                        margin: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                      ),
                    )
                ],
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

      case ShowType.resetPass:
        return _UserPasswdReset(
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
                    backgroundColor: Theme.of(context).dividerColor,
                    surfaceTintColor: Colors.transparent,
                    alignment: Alignment.center,
                    insetPadding: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 0, left: 0),
                    elevation: 2.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: SizedBox(
                        width: width,
                        height: height,
                        child: Column(
                          children: [
                            SizedBox(
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
          String? avatar = data['avatar'];
          if (avatar != null) {
            context.read<AppCubit>().setAvatar(avatar);
          } else {
            context.read<AppCubit>().setAvatar('');
          }
        }
      }
      context
          .read<AppCubit>()
          .setUserLogin(true, token: token, email: email, userName: userName);

      context.read<RecentlyCubit>().setUserLogin(true);
      context.read<FavoriteCubit>().setUserLogin(true);

      context.read<AppCubit>().startSync();

      widget.onClose(ShowType.login, ShowType.none);
    } else {
      requestCaptcha();

      toastMsg = context.read<AppCubit>().errorText(data['error']);
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
              child: Text(
                '${AppLocalizations.of(context)!.user_email}:',
              ),
            ),
            SizedBox(
              height: 26,
              width: 180.0,
              child: _textField(context, emailController,
                  AppLocalizations.of(context)!.user_email),
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
              child: Text(
                '${AppLocalizations.of(context)!.user_passwd}:',
              ),
            ),
            SizedBox(
              height: 26,
              width: 180.0,
              child: _textField(context, passwdController,
                  AppLocalizations.of(context)!.user_passwd,
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
              child: Text(
                '${AppLocalizations.of(context)!.user_captcha}:',
              ),
            ),
            Container(
              height: 26,
              width: 112.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _textField(context, codeController,
                  AppLocalizations.of(context)!.user_captcha),
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
                          ? Text(
                              AppLocalizations.of(context)!.user_refresh,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
              child: Text("${AppLocalizations.of(context)!.user_auto_signup}:"),
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
              AppLocalizations.of(context)!.user_signup_using_other,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
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
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12.0),
              child: InkClick(
                onTap: () {
                  widget.onClose(ShowType.register, ShowType.resetPass);
                },
                child: Text(
                  AppLocalizations.of(context)!.user_forgot_passwd,
                  style: const TextStyle(
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueAccent),
                ),
              ),
            ),
            Container(
              height: 26,
              width: 60.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: MaterialButton(
                color: Colors.deepPurpleAccent,
                onPressed: () {
                  widget.onClose(widget.from, ShowType.reward);
                },
                child: Text(
                  AppLocalizations.of(context)!.user_signup,
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 26,
              width: 60.0,
              child: MaterialButton(
                color: Colors.redAccent,
                onPressed: () {
                  if (!signinLoading) {
                    String toastMsg = '';
                    if (emailController.text.isEmpty) {
                      toastMsg += 'email 为空\n';
                    } else if (emailController.text.isNotEmpty &&
                        !_isEmailValid(emailController.text)) {
                      toastMsg += 'email 格式不正确\n';
                    } else if (passwdController.text.isEmpty) {
                      toastMsg += '密码为空\n';
                    } else if (codeController.text.isEmpty) {
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
                  }
                },
                child: signinLoading
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
                        AppLocalizations.of(context)!.user_signin,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
              ),
            )
          ],
        ),
        const Spacer(),
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
    {bool obscureText = false,
    bool readOnly = false,
    FocusNode? focusNode,
    Widget? suffix,
    void Function(String)? onSubmitted}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    readOnly: readOnly,
    autocorrect: false,
    obscuringCharacter: '*',
    obscureText: obscureText,
    cursorWidth: 1.0,
    showCursor: !readOnly,
    cursorColor: Theme.of(context).textTheme.bodyMedium!.color!,
    style: const TextStyle(fontSize: 14.0),
    decoration: InputDecoration(
      suffix: suffix,
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
      debugPrint('onSubmitted');
      if (onSubmitted != null) {
        onSubmitted(value);
      }
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
          child: const Column(
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Spacer(),
              InkClick(
                onTap: () {
                  ShowType next = ShowType.register;
                  if (ShowType.none != widget.from) {
                    next = widget.from;
                  }
                  widget.onClose(ShowType.reward, next);
                },
                child: Text(
                  AppLocalizations.of(context)!.user_skip,
                  style:
                      const TextStyle(fontSize: 12.0, color: Colors.blueAccent),
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

  bool signupLoading = false;

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
      String toastMsg = context.read<AppCubit>().errorText(data['error']);
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  void requestSignup(
      String email, String passwd, String captcha, String verifyCode) async {
    if (signupLoading) {
      return;
    }
    setState(() {
      signupLoading = true;
    });

    var data = await userApi.userSignup(
        email: email, passwd: passwd, captcha: captcha, verifyCode: verifyCode);
    setState(() {
      signupLoading = false;
    });
    if (data['error'] == 0) {
      context.read<AppCubit>().setUserLogin(false, email: email);
      context.read<AppCubit>().setAvatar('');

      String toastMsg = '用户注册成功，请登录！';
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
      widget.onClose(ShowType.register, ShowType.login);
    } else {
      String toastMsg = context.read<AppCubit>().errorText(data['error']);
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
              child: Text("${AppLocalizations.of(context)!.user_email}:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, emailController,
                  AppLocalizations.of(context)!.user_email),
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
              child: Text("${AppLocalizations.of(context)!.user_captcha}:"),
            ),
            Container(
              height: 26,
              width: 112.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _textField(context, codeController,
                  AppLocalizations.of(context)!.user_captcha),
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
                          ? Text(
                              AppLocalizations.of(context)!.user_refresh,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                        AppLocalizations.of(context)!.user_send_verify_code,
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_verify_code}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(
                          context,
                          verifyCodeController,
                          "${AppLocalizations.of(context)!.user_verify_code}:",
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwdController,
                            AppLocalizations.of(context)!.user_passwd,
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_re_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwd2Controller,
                            AppLocalizations.of(context)!.user_re_passwd,
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
                            if (!signupLoading) {
                              String toastMsg = '';
                              if (emailController.text.isEmpty ||
                                  !_isEmailValid(emailController.text)) {
                                toastMsg += '邮箱地址为空或者无效\n';
                              } else if (codeController.text.isEmpty) {
                                toastMsg += '验证码为空\n';
                              } else if (verifyCodeController.text.isEmpty) {
                                toastMsg += '邮箱校验码为空\n';
                              } else if (passwdController.text.isEmpty ||
                                  passwd2Controller.text.isEmpty) {
                                toastMsg += '密码或重输密码框为空\n';
                              } else if (passwdController.text !=
                                  passwd2Controller.text) {
                                toastMsg += '两次输入的密码不一致\n';
                              } else if (passwdController.text.length < 6) {
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
                          child: signupLoading
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
                                  AppLocalizations.of(context)!.user_signup,
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

class _UserPasswdReset extends StatefulWidget {
  final Function(ShowType, ShowType) onClose;
  final ShowType from;
  const _UserPasswdReset({required this.onClose, required this.from});

  @override
  State<_UserPasswdReset> createState() => _UserPasswdResetState();
}

class _UserPasswdResetState extends State<_UserPasswdReset> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();

  UserApi userApi = RadioRepository.instance.userApi;

  bool captchaLoading = false;
  Uint8List captcha = Uint8List(0);

  bool verifyCodeSending = false;
  bool verifyCodeSended = false;

  bool resetLoading = false;

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
    verifyCodeController.dispose();
  }

  void initReset() async {
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
    if (data['error'] == 0) {
      setState(() {
        verifyCodeSended = true;
      });
    } else {
      String toastMsg = context.read<AppCubit>().errorText(data['error']);
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  void requestResetPasswd(
      String email, String passwd, String captcha, String verifyCode) async {
    if (resetLoading) {
      return;
    }
    setState(() {
      resetLoading = true;
    });

    var data = await userApi.userResetPasswd(
        email: email, passwd: passwd, captcha: captcha, verifyCode: verifyCode);
    setState(() {
      resetLoading = false;
    });
    if (data['error'] == 0) {
      context.read<AppCubit>().setUserLogin(false, email: email);
      context.read<AppCubit>().setAvatar('');
      String toastMsg = '密码重置成功，请登录！';
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
      widget.onClose(ShowType.resetPass, ShowType.login);
    } else {
      String toastMsg = context.read<AppCubit>().errorText(data['error']);
      showToast(toastMsg,
          position: const ToastPosition(
            align: Alignment.bottomCenter,
          ),
          duration: const Duration(seconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    initReset();
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
              child: Text("${AppLocalizations.of(context)!.user_email}:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, emailController,
                  AppLocalizations.of(context)!.user_email),
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
              child: Text("${AppLocalizations.of(context)!.user_captcha}:"),
            ),
            Container(
              height: 26,
              width: 112.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _textField(context, codeController,
                  AppLocalizations.of(context)!.user_captcha),
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
                          ? Text(
                              AppLocalizations.of(context)!.user_refresh,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                        AppLocalizations.of(context)!.user_send_verify_code,
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_verify_code}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(
                          context,
                          verifyCodeController,
                          AppLocalizations.of(context)!.user_verify_code,
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwdController,
                            AppLocalizations.of(context)!.user_passwd,
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
                        width: 180,
                        padding: const EdgeInsets.only(right: 8.0),
                      ),
                      Container(
                        height: 26,
                        width: 80.0,
                        margin: const EdgeInsets.only(right: 8.0),
                        child: MaterialButton(
                          color: Colors.deepPurpleAccent,
                          onPressed: () {
                            if (!resetLoading) {
                              String toastMsg = '';
                              if (emailController.text.isEmpty ||
                                  !_isEmailValid(emailController.text)) {
                                toastMsg += '邮箱地址为空或者无效\n';
                              } else if (codeController.text.isEmpty) {
                                toastMsg += '验证码为空\n';
                              } else if (verifyCodeController.text.isEmpty) {
                                toastMsg += '邮箱校验码为空\n';
                              } else if (passwdController.text.length < 6) {
                                toastMsg += '密码长度必须大于等于6\n';
                              }

                              if (toastMsg.isNotEmpty) {
                                showToast(toastMsg,
                                    position: const ToastPosition(
                                      align: Alignment.bottomCenter,
                                    ),
                                    duration: const Duration(seconds: 5));
                              } else {
                                requestResetPasswd(
                                    emailController.text,
                                    passwdController.text,
                                    codeController.text,
                                    verifyCodeController.text);
                              }
                            }
                          },
                          child: resetLoading
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
                                  AppLocalizations.of(context)!
                                      .user_reset_passwd,
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
  TextEditingController oldPasswdController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController passwd2Controller = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  FocusNode userNameFocusNode = FocusNode();

  UserApi userApi = RadioRepository.instance.userApi;

  Uint8List captcha = Uint8List(0);

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> userProducts = [];

  bool isPasswdModifying = false;
  bool isRequestPasswdModifying = false;
  bool isRequestSignouting = false;
  bool isRequestAvatarModifying = false;
  bool isRequestUserNameModifying = false;
  List<String> isRequestOpenProducting = List.empty(growable: true);

  Uint8List avatarData = Uint8List(0);

  bool isInit = false;

  int avatarChg = -1;

  String userOldName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    oldPasswdController.dispose();
    passwdController.dispose();
    passwd2Controller.dispose();
    userNameController.dispose();
    userNameFocusNode.dispose();
  }

  void initDetail() async {
    if (mounted && !isInit) {
      isInit = true;

      userNameController.text =
          context.select<AppCubit, String>((value) => value.state.userName);

      reloadProducts();

      userNameFocusNode.addListener(() {
        if (!userNameFocusNode.hasFocus) {
          context.read<AppCubit>().setEditing(false);
          requestUserNameModify();
        } else {
          context.read<AppCubit>().setEditing(true);
        }
      });
    }
  }

  void reloadProducts() async {
    var data = await userApi.userProducts();
    if (data['error'] == 0) {
      products.clear();
      for (var element in (data['products'] as List)) {
        products.add(element);
      }

      data = await userApi.userOpenProducts();
      userProducts.clear();
      if (data['error'] == 0) {
        for (var element in (data['products'] as List)) {
          userProducts.add(element);
        }
      }
      setState(() {});
    }
  }

  void requestUserNameModify() async {
    if (userNameController.text != userOldName && !isRequestUserNameModifying) {
      setState(() {
        isRequestUserNameModifying = true;
      });

      var data = await userApi.userModify(userName: userNameController.text);

      setState(() {
        isRequestUserNameModifying = false;
      });

      if (data['error'] == 0) {
        context
            .read<AppCubit>()
            .setUserLogin(true, userName: userNameController.text);
      } else {
        userNameController.text = userOldName;
      }
    }
  }

  void requestModifyPasswd() async {
    if (!isRequestPasswdModifying) {
      setState(() {
        isRequestPasswdModifying = true;
      });

      var data = await userApi.userModify(
          passwd: oldPasswdController.text, newPassword: passwdController.text);

      setState(() {
        isRequestPasswdModifying = false;
      });

      if (data['error'] == 0) {
        context
            .read<AppCubit>()
            .setUserLogin(true, userName: userNameController.text);

        showToast('修改密码成功',
            position: const ToastPosition(
              align: Alignment.bottomCenter,
            ),
            duration: const Duration(seconds: 5));
      } else {
        showToast(context.read<AppCubit>().errorText(data['error']),
            position: const ToastPosition(
              align: Alignment.bottomCenter,
            ),
            duration: const Duration(seconds: 5));
      }
    }
  }

  void requestSignout() async {
    if (!isRequestSignouting) {
      setState(() {
        isRequestSignouting = true;
      });

      await userApi.userSignout();

      setState(() {
        isRequestSignouting = false;
      });

      widget.onClose(ShowType.userinfo, ShowType.none);
      context
          .read<AppCubit>()
          .setUserLogin(false, userName: userNameController.text);
      context.read<RecentlyCubit>().setUserLogin(false);
      context.read<FavoriteCubit>().setUserLogin(false);
    }
  }

  void requestOpenProduct(String product) async {
    var statusProduct = isRequestOpenProducting.firstWhere(
      (element) => element == product,
      orElse: () => '',
    );

    bool requesting = false;
    if (statusProduct.isNotEmpty) {
      requesting = true;
    }

    if (!requesting) {
      setState(() {
        isRequestOpenProducting.add(product);
      });

      var data = await userApi.userOpenProduct(product: product);
      if (data['error'] != 0) {
        showToast(context.read<AppCubit>().errorText(data['error']),
            position: const ToastPosition(
              align: Alignment.bottomCenter,
            ),
            duration: const Duration(seconds: 5));
      } else {
        reloadProducts();
      }

      setState(() {
        isRequestOpenProducting.remove(product);
      });
    }
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
      toastMsg = context.read<AppCubit>().errorText(data['error']);
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
        if (avatar != null && avatar.isNotEmpty) {
          avatarData = base64Decode(avatar);
        } else {
          avatarData = Uint8List(0);
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

    String userEmail =
        context.select<AppCubit, String>((value) => value.state.userEmail);

    userOldName =
        context.select<AppCubit, String>((value) => value.state.userName);

    initDetail();

    return Column(
      children: [
        const SizedBox(
          height: 12.0,
        ),
        InkClick(
          onTap: () async {
            if (!isRequestAvatarModifying) {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.image);

              if (result != null) {
                File file = File(result.files.single.path!);
                requestModifyAvatar(file);
              }
              await windowManager.orderFront();
            }
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
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
              if (isRequestAvatarModifying)
                Center(
                  child: Container(
                    height: 80.0,
                    width: 80.0,
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color!,
                    ),
                  ),
                ),
            ],
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
              child: Text("${AppLocalizations.of(context)!.user_email}:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              alignment: Alignment.centerLeft,
              child: Text(userEmail),
            ),
            Container(
              height: 26,
              width: 80,
              padding: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text("${AppLocalizations.of(context)!.user_name}:"),
            ),
            SizedBox(
              height: 26,
              width: 180.0,
              child: _textField(context, userNameController,
                  AppLocalizations.of(context)!.user_name,
                  readOnly: isRequestUserNameModifying,
                  focusNode: userNameFocusNode,
                  suffix: isRequestUserNameModifying
                      ? SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        )
                      : null,
                  onSubmitted: (_) => requestUserNameModify()),
            ),
            const Spacer(),
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
                color:
                    !isPasswdModifying ? Colors.blueAccent : Colors.redAccent,
                onPressed: () {
                  if (isPasswdModifying) {
                    String toastMsg = '';
                    if (passwdController.text.isEmpty ||
                        passwd2Controller.text.isEmpty ||
                        oldPasswdController.text.isEmpty) {
                      toastMsg += '密码框为空\n';
                    } else if (passwdController.text !=
                        passwd2Controller.text) {
                      toastMsg += '两次输入的密码不一致\n';
                    } else if (passwdController.text.length < 6) {
                      toastMsg += '密码长度必须大于等于6\n';
                    } else if (oldPasswdController.text !=
                        passwd2Controller.text) {
                      toastMsg += '新密码和旧密码一致\n';
                    }

                    if (toastMsg.isNotEmpty) {
                      showToast(toastMsg,
                          position: const ToastPosition(
                            align: Alignment.bottomCenter,
                          ),
                          duration: const Duration(seconds: 5));
                    } else {
                      requestModifyPasswd();
                    }
                  } else {
                    setState(() {
                      passwdController.text = '';
                      passwd2Controller.text = '';
                      oldPasswdController.text = '';
                      isPasswdModifying = true;
                    });
                  }
                },
                child: isRequestPasswdModifying
                    ? SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          color: Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                      )
                    : Text(
                        !isPasswdModifying
                            ? AppLocalizations.of(context)!.user_modify_passwd
                            : AppLocalizations.of(context)!.user_submit,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
              ),
            ),
            isPasswdModifying && !isRequestPasswdModifying
                ? Container(
                    height: 26,
                    margin: const EdgeInsets.only(left: 10.0, right: 190),
                    child: MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        setState(() {
                          isPasswdModifying = !isPasswdModifying;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cmm_cancel,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 280,
                  ),
            SizedBox(
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
                        AppLocalizations.of(context)!.user_quit,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
              ),
            ),
            const Spacer(),
          ],
        ),
        isPasswdModifying
            ? Column(
                children: [
                  const SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        height: 26,
                        width: 80,
                        padding: const EdgeInsets.only(right: 8.0),
                        alignment: Alignment.centerRight,
                        child: Text(
                            "${AppLocalizations.of(context)!.user_old_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, oldPasswdController,
                            AppLocalizations.of(context)!.user_old_passwd,
                            obscureText: true),
                      ),
                      const SizedBox(
                        width: 260,
                      ),
                      const Spacer(),
                    ],
                  ),
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
                        child: Text(
                            "${AppLocalizations.of(context)!.user_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwdController,
                            AppLocalizations.of(context)!.user_passwd,
                            obscureText: true),
                      ),
                      Container(
                        height: 26,
                        width: 80,
                        padding: const EdgeInsets.only(right: 8.0),
                        alignment: Alignment.centerRight,
                        child: Text(
                            "${AppLocalizations.of(context)!.user_re_passwd}:"),
                      ),
                      SizedBox(
                        height: 26,
                        width: 180.0,
                        child: _textField(context, passwd2Controller,
                            AppLocalizations.of(context)!.user_re_passwd,
                            obscureText: true),
                      ),
                      const Spacer(),
                    ],
                  )
                ],
              )
            : Container(),
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
                '${AppLocalizations.of(context)!.user_apps_info}:',
                style: const TextStyle(
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
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.user_app_name),
              fixedWidth: 60.0),
          DataColumn2(label: Text(AppLocalizations.of(context)!.user_app_desc)),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.user_app_time),
              fixedWidth: 150.0),
          DataColumn2(
              label: Text(AppLocalizations.of(context)!.user_app_op),
              fixedWidth: 50.0),
        ],
        empty: _empty(),

        rows: products.asMap().entries.map(
          (e) {
            int index = e.key;
            Map<String, dynamic> map = e.value;

            String product = map['product'];
            String desc = map['desc'];
            String time = DateFormat("yyyy-MM-dd HH:mm:ss").format(
                DateTime.fromMillisecondsSinceEpoch(map['update_time'] * 1000));

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
                DataCell(
                  Container(
                    height: 26,
                    width: 50,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                        color: isOpen ? Colors.black45 : Colors.redAccent,
                        borderRadius: BorderRadius.circular(4.0)),
                    child: InkClick(
                      onTap: () {
                        if (!isOpen) {
                          requestOpenProduct(product);
                        }
                      },
                      child: !isRequestOpenProducting.contains(product)
                          ? Text(
                              isOpen
                                  ? AppLocalizations.of(context)!
                                      .user_app_opened
                                  : AppLocalizations.of(context)!.user_app_open,
                              style: const TextStyle(
                                fontSize: 10.0,
                              ),
                            )
                          : SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}
