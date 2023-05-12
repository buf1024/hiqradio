import 'package:flutter/material.dart';

class WinReady extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onReady;
  const WinReady({super.key, required this.child, this.onReady});

  @override
  State<WinReady> createState() => _WinReadyState();
}

class _WinReadyState extends State<WinReady> {
  bool isReady = false;
  bool isDispose = false;
  @override
  void initState() {
    super.initState();
    _winReady();
  }

  @override
  void dispose() {
    super.dispose();
    isDispose = true;
  }

  void _winReady() async {
    if (widget.onReady != null) {
      await widget.onReady!.call();
    }
    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isReady ? widget.child : Container();
  }
}
