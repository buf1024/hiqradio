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
import 'package:hiqradio/src/views/phone/userinfo_page.dart';

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

    String userName =
        context.select<AppCubit, String>((value) => value.state.userName);

    String userEmail =
        context.select<AppCubit, String>((value) => value.state.userEmail);

    Color dividerColor = Theme.of(context).dividerColor;

    int avatarChgTag =
        context.select<AppCubit, int>((value) => value.state.avatarChgTag);

    getUserAvatar(avatarChgTag);
    initUserInfo(isLogin);

    return InkClick(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const UserInfoPage(),
          ),
        );
      },
      child: Row(
        children: [
          isLogin
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
                  padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: dividerColor),
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(
                    IconFont.notsignin,
                    size: 40.0,
                  ),
                ),
          Expanded(
            child: isLogin
                ? Container(
                    margin: const EdgeInsets.only(
                        left: 18.0, top: 2.0, bottom: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          userEmail,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : Container(),
          )
        ],
      ),
    );
  }
}
