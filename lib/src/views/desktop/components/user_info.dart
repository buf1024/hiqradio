import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/repository/userapi/userapi.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';

enum ShowType { login, reward, register, none }

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  OverlayEntry? userOverlay;

  @override
  Widget build(BuildContext context) {
    return InkClick(
      onTap: () => _onShowUser(ShowType.login),
      child: Container(
        width: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: const Image(image: AssetImage('assets/images/login.png')),
        ),
      ),
    );
  }

  void _onCloseContent(ShowType next) {
    _closeShowUser();
    if (ShowType.none != next) {
      _onShowUser(next);
    }
  }

  Widget? _getContent(ShowType type) {
    switch (type) {
      case ShowType.login:
        return _UserLogin(
          onClose: _onCloseContent,
        );
      case ShowType.reward:
        return _UserReward(
          onClose: _onCloseContent,
        );
      case ShowType.register:
        return _UserRegister(onClose: _onCloseContent,);
      case ShowType.none:
        return null;
    }
  }

  void _onShowUser(ShowType type) {
    double width = 300.0;
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
              padding: const EdgeInsets.only(top: kTitleBarHeight),
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
                              child: _getContent(type),
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
  final Function(ShowType)? onClose;
  const _UserLogin({this.onClose});

  @override
  State<_UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<_UserLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  late UserApi userApi;

  bool captchaLoading = false;
  bool signinLoading = false;

  Uint8List captcha = Uint8List(0);

  @override
  void initState() {
    super.initState();

    userApi = RadioRepository.instance.userApi;
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwdController.dispose();
    codeController.dispose();
  }

  void _init() async {
    captchaRequest();
  }

  void captchaRequest() async {
    debugPrint('request..');
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
        debugPrint('${captcha.length}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildLogin();
  }

  Widget _buildLogin() {
    debugPrint('loading: $captchaLoading');
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
              onTap: () => captchaRequest(),
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
                              '重试?',
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
        SizedBox(
          height: 6.0,
        ),
        Row(
          children: [
            Container(
              height: 26,
              width: 132,
              padding: const EdgeInsets.only(right: 8.0),
            ),
            Container(
              height: 26,
              width: 60.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: MaterialButton(
                color: Colors.deepPurpleAccent,
                onPressed: () {
                  widget.onClose!(ShowType.reward);
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
                  widget.onClose!(ShowType.none);
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

Widget _textField(
    BuildContext context, TextEditingController controller, String hintText,
    {bool obscureText = false}) {
  return TextField(
    controller: controller,
    autocorrect: false,
    obscuringCharacter: '*',
    obscureText: obscureText,
    cursorWidth: 1.0,
    showCursor: true,
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
  final Function(ShowType)? onClose;
  const _UserReward({this.onClose});

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
        Spacer(),
        Container(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Spacer(),
              InkClick(
                onTap: () => widget.onClose!(ShowType.register),
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
   final Function(ShowType)? onClose;
  const _UserRegister({this.onClose});

  @override
  State<_UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<_UserRegister> {
  @override
  Widget build(BuildContext context) {
    return Text('uSER register');
  }
}
