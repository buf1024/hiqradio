import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class Crypt {
  String tab = '0123456789abcdefghijklmnopqrstuvwxyz';
  Crypt._();
  static Crypt instance = Crypt._();

  String? encryptLicense(String productId, String date) {
    // 32 长度 时间8 密钥24填充0 date格式yyyyMMdd
    if (productId.length != 2) {
      return null;
    }
    String key = '';
    for (int i = 0; i < 24; i++) {
      if (i == 10) {
        key += productId.toLowerCase().substring(0, 1);
      } else if (i == 18) {
        key += productId.toLowerCase().substring(1);
      } else {
        String charCode =
            String.fromCharCode(tab.codeUnitAt(Random().nextInt(tab.length)));
        key = '$key$charCode';
      }
    }
    for (int i = 0; i < 8; i++) {
      key += '0';
    }
    // stdout.writeln('key=$key');

    date = date.substring(2);
    int iDate = int.parse(date);
    Uint8List u8List = Uint8List(4)
      ..buffer.asByteData().setInt32(0, iDate, Endian.big);

    Key eKey = Key.fromUtf8(key);
    IV iv = IV.fromLength(16);

    Encrypter encrypter = Encrypter(AES(eKey, padding: null));

    String eStr = encrypter.encryptBytes(u8List.toList(), iv: iv).base16;

    key = key.substring(0, 24);

    int pos = key.codeUnitAt(0) % 24 + 1;

    String posKey = key.substring(0, 1);
    String p1Key = '';
    if (pos > 1) {
      p1Key = key.substring(1, pos);
    }
    String p2Key = '';
    if (pos < 24) {
      p2Key = key.substring(pos);
    }

    key = '$posKey$p1Key$eStr$p2Key';

    // stdout
    //     .writeln('index: $posKey, p1: $p1Key, p2: $p2Key, data:$eStr key=$key');

    return key;
  }

  String? decryptLicense(String productId, String data) {
    if (productId.length != 2 || data.length != 32) {
      return null;
    }
    int pos = data.codeUnitAt(0) % 24 + 1;
    String eData = data.substring(pos, pos + 8);
    data = data.substring(0, pos) + data.substring(pos + 8);
    String key = '';
    if (pos == 24) {
      key = data.substring(0, pos);
    } else {
      key = '${data.substring(0, pos)}${data.substring(pos)}';
    }
    if (key.length != 24) {
      return null;
    }
    String eProductId = key.substring(10, 11) + key.substring(18, 19);
    if (eProductId != productId) {
      return null;
    }

    key = '${key}00000000';
    // stdout.writeln('key=$key, data=$eData');

    Key eKey = Key.fromUtf8(key);
    IV iv = IV.fromLength(16);

    Encrypter encrypter = Encrypter(AES(eKey, padding: null));
    Encrypted encrypted = Encrypted.fromBase16(eData);

    List<int> decryptBytes = encrypter.decryptBytes(encrypted, iv: iv);
    int iData = ByteData.view(Uint8List.fromList(decryptBytes).buffer)
        .getInt32(0, Endian.big);
    // stdout.writeln('dec: $iData');
    return '20$iData';
  }
}
