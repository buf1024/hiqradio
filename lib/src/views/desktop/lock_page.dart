import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  final TextEditingController editingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isVisible = false;
  String md5pass = 'e10adc3949ba59abbe56e057f20f883e';
  String errText = '';
  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: backgroundColor,
      body: Center(
        child: Row(
          children: [
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text.rich(
                //   TextSpan(children: [TextSpan(text: '勇于承认错误才是生存下去第一要素！')]),
                // ),
                // Text.rich(
                //   TextSpan(children: [TextSpan(text: '出现亏损时必须无情！')]),
                // ),
                const SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    Container(
                      width: 250,
                      padding: const EdgeInsets.all(2.0),
                      child: TextField(
                        controller: editingController,
                        focusNode: focusNode,
                        autofocus: true,
                        obscureText: !isVisible,
                        autocorrect: false,
                        obscuringCharacter: '*',
                        cursorWidth: 1.0,
                        cursorColor: Colors.grey.withOpacity(0.8),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: errText.isEmpty
                                      ? Colors.grey.withOpacity(0.8)
                                      : Colors.red.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(5)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: errText.isEmpty
                                      ? Colors.grey.withOpacity(0.8)
                                      : Colors.red.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(5)),
                          suffixIcon: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 6.0),
                            child: InkWell(
                              radius: 0,
                              hoverColor: Colors.black.withOpacity(0),
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Icon(
                                isVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: Colors.grey.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        onSubmitted: (text) {
                          focusNode.requestFocus();
                          onSubmitted();
                        },
                        onChanged: (_) => setState(() => errText = ''),
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    ElevatedButton(
                        onPressed: () => onSubmitted(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withOpacity(0.8),
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Text(
                            '解锁',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                errText.isEmpty
                    ? const SizedBox(
                        height: 50.0,
                      )
                    : SizedBox(
                        height: 50.0,
                        child: Text(
                          errText,
                          style: TextStyle(
                              color: Colors.red.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0),
                        ),
                      ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void onSubmitted() {
    String md5sum = md5.convert(utf8.encode(editingController.text)).toString();
    if (md5sum != md5pass) {
      setState(() {
        errText = '你输入的密码是不正确滴，你可以无限次数重试！';
      });
    } else {
      Navigator.of(context).pop();
    }
  }
}
