## 技巧
-  title bar包括TextEdit不能选择文本问题
 windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 为了使有TextEdit的Frameless window Title bar 的可以选择文本
    // 只能如此，猥琐发育
    await windowManager.setMovable(false);


rb.countries()
[{'name': 'China', 'iso_3166_1': 'CN', 'stationcount': 2133}]

rb.countrycodes()
[{'name': 'ZW', 'stationcount': 3}]

rb.states(country='China')
[{'name': 'Amur River', 'country': 'China', 'stationcount': 40}]


