
[简体中文](README-zh_CN.md)

HiqRadio is a simple & power network radio，it is base on [OpenRadio](https://www.radio-browser.info/ "OpenRadio") api，and it is a Flutter application/app. It supports desktop platform: Windows/Linux/Mac, and mobile platform: android/ios, and is well tested in Mac and android.

Web is support too, but only for platform integrity. Is hard to use only one code to compile to web, so I checkout a new branch 'web' to separate the code. It is not as so much functionality as other platforms. visit it: [Github Page](https://luoguochun.cn/hiqradio/) or
[Vercel](https://buf1024-github-io.vercel.app/hiqradio)。

### Mainly function

* stations cache / search
* play history / timer play
* record / favorite group / export / import
* driver mode
* system tray
* ……

### Screen

Desktop(Mac)：

<table>
    <tr>
     <td><center><img src="images/mac1.png" width="45%"></center></td>
     <td><center><img src="images/mac2.png" width="45%"></center></td>
    </tr>
</table>



Mobile (android)：


<table>
    <tr>
     <td><center><img src="images/android1.jpg" width="45%"></center></td>
     <td><center><img src="images/android2.jpg" width="45%"></center></td>
    </tr>
    <tr>
     <td><center><img src="images/android3.jpg" width="45%"></center></td>
     <td><center><img src="images/android4.jpg" width="45%"></center></td>
    </tr>
</table>


‍

### Compile

```shel
## flutter version, other version is note grantee success.
$ flutter --version 
Flutter 3.13.0 • channel stable • git@github.com:flutter/flutter.git
Framework • revision efbf63d9c6 (4 weeks ago) • 2023-08-15 21:05:06 -0500
Engine • revision 1ac611c64e
Tools • Dart 3.1.0 • DevTools 2.25.

$ flutter pub get 
$ flutter gen-l10n 
$ flutter build macos --release
```

Enjoy it.
