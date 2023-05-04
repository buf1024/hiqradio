import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hiqradio/src/repository/radioapi/radioapi.dart';

void main() async {
  RadioApi api = await RadioApi.create();
    var jsStr = await api.countries();
    String? x;
    print('aa/$x/bb');
    File fileOut = File('tt.json');
    fileOut.writeAsString(jsonEncode(jsStr));
    


}