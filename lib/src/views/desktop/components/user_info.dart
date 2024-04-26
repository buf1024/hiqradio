import 'dart:collection';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiqradio/src/app/iconfont.dart';
import 'package:hiqradio/src/repository/repository.dart';
import 'package:hiqradio/src/repository/userapi/userapi.dart';
import 'package:hiqradio/src/views/components/ink_click.dart';
import 'package:hiqradio/src/views/desktop/utils/constant.dart';
import 'package:intl/intl.dart';

enum ShowType { login, reward, register, userinfo, none }

class UserInfo extends StatefulWidget {
  final ShowType showType;
  const UserInfo({super.key, required this.showType});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  OverlayEntry? userOverlay;

  @override
  Widget build(BuildContext context) {
    return InkClick(
      onTap: () => _onShowUser(widget.showType),
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
          onClose: (next) => _onCloseContent(next),
        );
      case ShowType.reward:
        return _UserReward(
          onClose: (next) => _onCloseContent(next),
        );
      case ShowType.register:
        return _UserRegister(
          onClose: (next) => _onCloseContent(next),
        );
      case ShowType.userinfo:
        return _UserRegisterInfo(
          onClose: (next) => _onCloseContent(next),
        );
      case ShowType.none:
        return null;
    }
  }

  void _onShowUser(ShowType type) {
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
              value: true,
              onChanged: (value) {
                // if (value != null && value != autoStart) {
                //   context.read<AppCubit>().setAutoStart(value);
                // }
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
                },
                child: Text(
                  '发送校验码',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            )
          ],
        ),
        Column(
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
                    passwdController,
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
                  child: _textField(context, passwdController, "重输登录密码",
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
                      widget.onClose!(ShowType.login);
                    },
                    child: Text(
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
        ),
        Spacer(),
      ],
    );
  }
}

class _UserRegisterInfo extends StatefulWidget {
  final Function(ShowType)? onClose;
  const _UserRegisterInfo({this.onClose});

  @override
  State<_UserRegisterInfo> createState() => _UserRegisterInfoState();
}

class _UserRegisterInfoState extends State<_UserRegisterInfo> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  late UserApi userApi;

  bool captchaLoading = false;
  bool signinLoading = false;

  Uint8List captcha = Uint8List(0);

  List<Map<String, dynamic>> products = [];

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
    Map<String, dynamic> aa = HashMap();

    products.add(aa);
  }

  void captchaRequest() async {
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
    return Column(
      children: [
        const SizedBox(
          height: 12.0,
        ),
        InkClick(
          onTap: () => {},
          child: Container(
            width: 80.0,
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: const Image(image: AssetImage('assets/images/login.png')),
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
              child: _textField(context, emailController, "注册的邮箱"),
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
              child: _textField(context, emailController, "用户名"),
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
              child: Text("密码:"),
            ),
            Container(
              height: 26,
              width: 180.0,
              child: _textField(context, passwdController, "登录密码",
                  obscureText: true),
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
              child: _textField(context, passwdController, "重输登录密码",
                  obscureText: true),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(
          height: 6.0,
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
                color: Colors.blueAccent,
                onPressed: () {
                  // widget.onClose!(ShowType.none);
                },
                child: Text(
                  '信息修改',
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 280,
            ),
            Container(
              height: 26,
              child: MaterialButton(
                color: Colors.redAccent,
                onPressed: () {
                  // widget.onClose!(ShowType.none);
                },
                child: Text(
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
    //     context.select<RecentlyCubit, bool>((value) => value.state.isLoading);
    // if (isLoading) {
    //   return Center(
    //     child: Container(
    //       height: 40.0,
    //       width: 40.0,
    //       padding: const EdgeInsets.all(4.0),
    //       child: CircularProgressIndicator(
    //         strokeWidth: 1.0,
    //         color: Colors.white.withOpacity(0.8),
    //       ),
    //     ),
    //   );
    // }
    return Center(
      child: Text(
        // '暂无播放记录',
        'AppLocalizations.of(context)!.recently_empty',
        style: const TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
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
            return DataRow2(
              // selected: isSelected,
              color: index.isEven
                  ? MaterialStateProperty.all(Colors.grey.withOpacity(0.05))
                  : null,
              onSecondaryTapDown: (details) {
                // showContextMenu(details.globalPosition);
              },
              onDoubleTap: () {
                // if (isPlaying && playingStation != null) {
                //   context.read<RecentlyCubit>().updateRecently(playingStation);
                // }
                // context.read<AppCubit>().play(station);
                // context.read<RecentlyCubit>().addRecently(station);
              },
              cells: [
                DataCell(
                  Text('hiqradio'),
                ),
                DataCell(
                  Text(
                    '一款收音机工具',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    DateFormat("yyyy-MM-dd HH:mm:ss").format(
                        DateTime.fromMillisecondsSinceEpoch(1714104413723)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4.0)),
                  child: InkClick(
                    onTap: () {
                      // widget.onClose!(ShowType.none);
                    },
                    child: Text(
                      '已注册',
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
