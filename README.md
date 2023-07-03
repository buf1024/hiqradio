## 技巧
-  title bar包括TextEdit不能选择文本问题
 windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 为了使有TextEdit的Frameless window Title bar 的可以选择文本
    // 只能如此，猥琐发育
    await windowManager.setMovable(false);

 }
- StatefulBuilder 设置Dialog bottomSheet等状态
## 问题
Flutter 不支持条件import，所以，有些涉及平台相关的代码，有些做不到，就必须删代码编译