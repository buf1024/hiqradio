import 'package:flutter/material.dart';

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
    return [
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            '语言',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.8)),
          ),
          subtitle: Text(
            '当前语言: 跟随系统',
            style:
                TextStyle(fontSize: 12.0, color: Colors.white.withOpacity(0.8)),
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            '自动播放',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.9)),
          ),
          subtitle: Text(
            '启动应用时自动播放上次电台',
            style:
                TextStyle(fontSize: 12.0, color: Colors.grey.withOpacity(0.8)),
          ),
          trailing: Checkbox(
            splashRadius: 0,
            checkColor: Colors.grey.withOpacity(0.8),
            focusColor: Colors.black.withOpacity(0),
            hoverColor: Colors.black.withOpacity(0),
            activeColor: Colors.black.withOpacity(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            side: MaterialStateBorderSide.resolveWith((states) =>
                BorderSide(width: 1.0, color: Colors.grey.withOpacity(0.8))),
            value: true,
            onChanged: (value) {},
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
          splashColor: Colors.black.withOpacity(0),
          title: Text(
            '耳机拔出停止',
            style:
                TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.9)),
          ),
          subtitle: Text(
            '耳机拔出停止播放',
            style:
                TextStyle(fontSize: 12.0, color: Colors.grey.withOpacity(0.8)),
          ),
          trailing: Checkbox(
            splashRadius: 0,
            checkColor: Colors.grey.withOpacity(0.8),
            focusColor: Colors.black.withOpacity(0),
            hoverColor: Colors.black.withOpacity(0),
            activeColor: Colors.black.withOpacity(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0),
            ),
            side: MaterialStateBorderSide.resolveWith((states) =>
                BorderSide(width: 1.0, color: Colors.grey.withOpacity(0.8))),
            value: true,
            onChanged: (value) {},
          ),
          onTap: () {},
          mouseCursor: SystemMouseCursors.click),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          '关于本应用',
          style:
              TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.9)),
        ),
        onTap: () {},
      ),
      ListTile(
        splashColor: Colors.black.withOpacity(0),
        title: Text(
          '版本: 1.0.0.git hash',
          style:
              TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.9)),
        ),
        onTap: () {},
      )
    ];
  }
}
