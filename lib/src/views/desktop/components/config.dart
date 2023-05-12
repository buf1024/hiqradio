import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiqradio/src/blocs/app_cubit.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: _buildConfigItem(),
      ),
    );
  }

  List<Widget> _buildConfigItem() {
    bool autoStart =
        context.select<AppCubit, bool>((value) => value.state.autoStart);
    bool autoStop =
        context.select<AppCubit, bool>((value) => value.state.autoStop);
    return [
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: const Text(
            '语言',
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
          subtitle: const Text(
            '当前语言: 跟随系统',
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: const Text(
            '自动播放',
            style: TextStyle(fontSize: 14.0),
          ),
          subtitle: const Text('启动应用时自动播放上次电台'),
          trailing: Checkbox(
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
            value: autoStart,
            onChanged: (value) {
              if (value != null && value != autoStart) {
                context.read<AppCubit>().setAutoStart(value);
              }
            },
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: const Text(
            '耳机拔出停止',
            style: TextStyle(fontSize: 14.0),
          ),
          subtitle: const Text(
            '耳机拔出停止播放',
            style: TextStyle(fontSize: 12.0),
          ),
          trailing: Checkbox(
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
            value: autoStop,
            onChanged: (value) {
              if (value != null && value != autoStop) {
                context.read<AppCubit>().setAutoStop(value);
              }
            },
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: const Text(
          '关于本应用',
          style: TextStyle(fontSize: 14.0),
        ),
        onTap: () {},
      ),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: const Text(
          '版本: 1.0.0',
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        onTap: () {},
      )
    ];
  }
}
