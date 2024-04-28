import 'dart:convert';

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

enum ShowType { login, reward, register, userinfo, resetPass, none }

class PhoneUserInfo extends StatefulWidget {
  const PhoneUserInfo({super.key});

  @override
  State<PhoneUserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<PhoneUserInfo> {
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
        if (avatar != null && avatar.isNotEmpty) {
          debugPrint('avatar not empty');
          avatarData = base64Decode(avatar);
        } else {
          avatarData = Uint8List(0);
        }
        avatarChg = chgTag;
      });
    }
  }

  void initUserInfo(bool isLogin) async {
    if (mounted && !isInit) {
      isInit = true;

      if (isLogin) {
        var data = await userApi.userInfo();

        if (data['error'] == 0) {
          context.read<AppCubit>().setUserLogin(true,
              email: data['email'], userName: data['user_name']);
          context.read<RecentlyCubit>().setUserLogin(true);
          context.read<FavoriteCubit>().setUserLogin(true);

          context.read<AppCubit>().startSync();
        }
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
    initUserInfo(isLogin);

    return InkClick(
      onTap: () => _onShowUser(ShowType.none, type),
      child: isLogin
          ? SizedBox(
              width: 60.0,
              height: 60.0,
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
              width: 60.0,
              height: 60.0,
              margin: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                IconFont.notsignin,
                size: 26.0,
              ),
            ),
    );
  }

  Widget? _getContent(ShowType from, ShowType type) {
    // switch (type) {
    //   case ShowType.login:
    //     return _UserLogin(
    //       from: from,
    //       onClose: (from, next) => _onCloseContent(from, next),
    //     );
    //   case ShowType.reward:
    //     return _UserReward(
    //       from: from,
    //       onClose: (from, next) => _onCloseContent(from, next),
    //     );
    //   case ShowType.register:
    //     return _UserRegister(
    //       from: from,
    //       onClose: (from, next) => _onCloseContent(from, next),
    //     );
    //   case ShowType.userinfo:
    //     return _UserDetail(
    //       from: from,
    //       onClose: (from, next) => _onCloseContent(from, next),
    //     );

    //   case ShowType.resetPass:
    //     return _UserPasswdReset(
    //       from: from,
    //       onClose: (from, next) => _onCloseContent(from, next),
    //     );

    //   case ShowType.none:
    //     return null;
    // }
    return null;
  }

  void _onShowUser(ShowType from, ShowType type) {}
}
