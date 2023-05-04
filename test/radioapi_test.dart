import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hiqradio/src/repository/radioapi/radioapi.dart';

void main() async {
  RadioApi api = await RadioApi.create();
  // var str = await api.countries();
  // var str = await api.countrycodes(code: 'CN');
  // var str = await api.codecs(codec: 'aac');
  // var str = await api.states(country: 'China');
  // var str = await api.languages();
  // var str = await api.tags();
  // var str = await api.stationsByVotes(limit: 5);
  // var str = await api.stations();
  var str = await api.search(name: '经济', offset: 1, limit: 2);

  print('result: $str');
}
