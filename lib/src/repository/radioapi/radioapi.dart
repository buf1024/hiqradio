import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

class RadioApi {
  String userAgent = 'hiqradio/1.0';
  Dio dio = Dio();
  bool isInit = false;

  static final RadioApi _instance = RadioApi._();

  static Future<RadioApi> create() async {
    RadioApi api = RadioApi._instance;
    if (!api.isInit) {
      await api.initDio();
    }
    return api;
  }

  RadioApi._();

  Future<void> initDio() async {
    List<String> hosts = [];
    String hostName = 'all.api.radio-browser.info';

    List<InternetAddress> addresses = await InternetAddress.lookup(hostName);
    for (InternetAddress addr in addresses) {
      InternetAddress revAddr = await addr.reverse();
      hosts.add(revAddr.host);
    }
    var baseUrl = 'https://${hosts[Random().nextInt(hosts.length)]}';

    dio.options.baseUrl = baseUrl;
    Map<String, dynamic> headers = HashMap();
    headers['User-Agent'] = userAgent;
    dio.options.headers = headers;
    dio.options.responseType = ResponseType.json;
  }

  Future<dynamic> countries({String? code}) async {
    // [{"name":"Andorra","iso_3166_1":"AD","stationcount":7}]
    String url = code == null ? '/json/countries/' : '/json/countries/$code';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> countrycodes({String? code}) async {
    // [{'name': 'XK', 'stationcount': 13}]
    String url =
        code == null ? '/json/countrycodes/' : '/json/countrycodes/$code';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> codecs({String? codec}) async {
    // [{'name': 'AAC', 'stationcount': 13}]
    Response response = await dio.get('/json/codecs/');
    List<dynamic> data = response.data;
    if (codec != null) {
      data = data
          .where((element) =>
              codec.toLowerCase() == (element['name'] as String).toLowerCase())
          .toList();
    }
    return data;
  }

  Future<dynamic> states({String? country, String? state}) async {
    // [{'name': '上海', 'country': 'China', 'stationcount': 4}]
    Response response = await dio.get('/json/states/');
    List<dynamic> data = response.data;
    if (country != null) {
      data = data
          .where((element) =>
              country.toLowerCase() ==
              (element['country'] as String).toLowerCase())
          .toList();
    }
    if (state != null) {
      data = data
          .where((element) =>
              state.toLowerCase() == (element['name'] as String).toLowerCase())
          .toList();
    }
    return data;
  }

  Future<dynamic> languages({String? language}) async {
    // [{'name': 'xhosa', 'iso_639': 'xh', 'stationcount': 4}]
    String url =
        language == null ? '/json/languages/' : '/json/languages/$language';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> tags({String? tag}) async {
    // [{'name': 'alto lucero', 'stationcount': 1}]
    String url = tag == null ? '/json/tags/' : '/json/tags/$tag';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> stationsByVotes({required int limit}) async {
    // [{'changeuuid': 'abbf72c1-6ff9-4408-8402-3de417d3b52c',
    // 'stationuuid': '4a018de7-b452-4412-b86f-86254c5d53be',
    // 'serveruuid': None,
    // 'name': 'ABC Lounge Radio',
    // 'url': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'url_resolved': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'homepage': 'https://www.abc-lounge.com/radio/lounge-jazz-folk/#home',
    // 'favicon': '',
    // 'tags': 'ambient,chillout,easy listening,lounge,smooth jazz',
    // 'country': 'France',
    // 'countrycode': 'FR',
    // 'iso_3166_2': None,
    // 'state': '',
    // 'language': 'english,french',
    // 'languagecodes': 'en,fr',
    // 'votes': 3910,
    // 'lastchangetime': '2022-11-03 09:32:32',
    // 'lastchangetime_iso8601': '2022-11-03T09:32:32Z',
    // 'codec': 'MP3',
    // 'bitrate': 128,
    // 'hls': 0,
    // 'lastcheckok': 1,
    // 'lastchecktime': '2023-05-01 00:25:43',
    // 'lastchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastcheckoktime': '2023-05-01 00:25:43',
    // 'lastcheckoktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastlocalchecktime': '2023-05-01 00:25:43',
    // 'lastlocalchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'clicktimestamp': '2023-05-01 06:51:04',
    // 'clicktimestamp_iso8601': '2023-05-01T06:51:04Z',
    // 'clickcount': 492,
    // 'clicktrend': -15,
    // 'ssl_error': 0,
    // 'geo_lat': None,
    // 'geo_long': None,
    // 'has_extended_info': False}]
    String url = '/json/stations/topvote/$limit';
    Response response = await dio.get(url);
    return response.data;
  }
  Future<dynamic> stationsByUuid({required String uuid}) async {
    // [{'changeuuid': 'abbf72c1-6ff9-4408-8402-3de417d3b52c',
    // 'stationuuid': '4a018de7-b452-4412-b86f-86254c5d53be',
    // 'serveruuid': None,
    // 'name': 'ABC Lounge Radio',
    // 'url': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'url_resolved': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'homepage': 'https://www.abc-lounge.com/radio/lounge-jazz-folk/#home',
    // 'favicon': '',
    // 'tags': 'ambient,chillout,easy listening,lounge,smooth jazz',
    // 'country': 'France',
    // 'countrycode': 'FR',
    // 'iso_3166_2': None,
    // 'state': '',
    // 'language': 'english,french',
    // 'languagecodes': 'en,fr',
    // 'votes': 3910,
    // 'lastchangetime': '2022-11-03 09:32:32',
    // 'lastchangetime_iso8601': '2022-11-03T09:32:32Z',
    // 'codec': 'MP3',
    // 'bitrate': 128,
    // 'hls': 0,
    // 'lastcheckok': 1,
    // 'lastchecktime': '2023-05-01 00:25:43',
    // 'lastchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastcheckoktime': '2023-05-01 00:25:43',
    // 'lastcheckoktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastlocalchecktime': '2023-05-01 00:25:43',
    // 'lastlocalchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'clicktimestamp': '2023-05-01 06:51:04',
    // 'clicktimestamp_iso8601': '2023-05-01T06:51:04Z',
    // 'clickcount': 492,
    // 'clicktrend': -15,
    // 'ssl_error': 0,
    // 'geo_lat': None,
    // 'geo_long': None,
    // 'has_extended_info': False}]
    String url = '/json/stations/byuuid/$uuid';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> stations() async {
    // [{'changeuuid': 'abbf72c1-6ff9-4408-8402-3de417d3b52c',
    // 'stationuuid': '4a018de7-b452-4412-b86f-86254c5d53be',
    // 'serveruuid': None,
    // 'name': 'ABC Lounge Radio',
    // 'url': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'url_resolved': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'homepage': 'https://www.abc-lounge.com/radio/lounge-jazz-folk/#home',
    // 'favicon': '',
    // 'tags': 'ambient,chillout,easy listening,lounge,smooth jazz',
    // 'country': 'France',
    // 'countrycode': 'FR',
    // 'iso_3166_2': None,
    // 'state': '',
    // 'language': 'english,french',
    // 'languagecodes': 'en,fr',
    // 'votes': 3910,
    // 'lastchangetime': '2022-11-03 09:32:32',
    // 'lastchangetime_iso8601': '2022-11-03T09:32:32Z',
    // 'codec': 'MP3',
    // 'bitrate': 128,
    // 'hls': 0,
    // 'lastcheckok': 1,
    // 'lastchecktime': '2023-05-01 00:25:43',
    // 'lastchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastcheckoktime': '2023-05-01 00:25:43',
    // 'lastcheckoktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastlocalchecktime': '2023-05-01 00:25:43',
    // 'lastlocalchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'clicktimestamp': '2023-05-01 06:51:04',
    // 'clicktimestamp_iso8601': '2023-05-01T06:51:04Z',
    // 'clickcount': 492,
    // 'clicktrend': -15,
    // 'ssl_error': 0,
    // 'geo_lat': None,
    // 'geo_long': None,
    // 'has_extended_info': False}]
    String url = '/json/stations';
    Response response = await dio.get(url);
    return response.data;
  }

  Future<dynamic> search(
      {String? name,
      bool? nameExact,
      String? country,
      bool? countryExact,
      String? countrycode,
      String? state,
      bool? stateExact,
      String? language,
      bool? languageExact,
      String? tag,
      bool? tagExact,
      String? tagList,
      int? bitrateMin,
      int? bitrateMax,
      String? order,
      bool? reverse,
      int? offset,
      int? limit,
      bool? hidebroken}) async {
    // Args:
    //         name (str, optional): Name of the station.
    //         name_exact (bool, optional): Only exact matches, otherwise all
    //             matches (default: False).
    //         country (str, optional): Country of the station.
    //         country_exact (bool, optional): Only exact matches, otherwise
    //             all matches (default: False).
    //         countrycode (str, optional): 2-digit countrycode of the station
    //             (see ISO 3166-1 alpha-2)
    //         state (str, optional): State of the station.
    //         state_exact (bool, optional): Only exact matches, otherwise all
    //             matches. (default: False)
    //         language (str, optional): Language of the station.
    //         language_exact (bool, optional): Only exact matches, otherwise
    //             all matches. (default: False)
    //         tag (str, optional): Tag of the station.
    //         tag_exact (bool, optional): Only exact matches, otherwise all
    //             matches. (default: False)
    //         tag_list (str, optional): A comma-separated list of tag.
    //         bitrate_min (int, optional): Minimum of kbps for bitrate field of
    //             stations in result. (default: 0)
    //         bitrate_max (int, optional): Maximum of kbps for bitrate field of
    //             stations in result. (default: 1000000)
    //         order (str, optional): The result list will be sorted by: name,
    //             url, homepage, favicon, tags, country, state, language, votes,
    //             codec, bitrate, lastcheckok, lastchecktime, clicktimestamp,
    //             clickcount, clicktrend, random
    //         reverse (bool, optional): Reverse the result list if set to true.
    //             (default: false)
    //         offset (int, optional): Starting value of the result list from
    //             the database. For example, if you want to do paging on the
    //             server side. (default: 0)
    //         limit (int, optional): Number of returned datarows (stations)
    //             starting with offset (default 100000)
    //         hidebroken (bool, optional): do list/not list broken stations.
    //             Note: Not documented in the "Advanced Station Search".

    // [{'changeuuid': 'abbf72c1-6ff9-4408-8402-3de417d3b52c',
    // 'stationuuid': '4a018de7-b452-4412-b86f-86254c5d53be',
    // 'serveruuid': None,
    // 'name': 'ABC Lounge Radio',
    // 'url': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'url_resolved': 'https://eu1.fastcast4u.com/proxy/kpmxz?mp=/1',
    // 'homepage': 'https://www.abc-lounge.com/radio/lounge-jazz-folk/#home',
    // 'favicon': '',
    // 'tags': 'ambient,chillout,easy listening,lounge,smooth jazz',
    // 'country': 'France',
    // 'countrycode': 'FR',
    // 'iso_3166_2': None,
    // 'state': '',
    // 'language': 'english,french',
    // 'languagecodes': 'en,fr',
    // 'votes': 3910,
    // 'lastchangetime': '2022-11-03 09:32:32',
    // 'lastchangetime_iso8601': '2022-11-03T09:32:32Z',
    // 'codec': 'MP3',
    // 'bitrate': 128,
    // 'hls': 0,
    // 'lastcheckok': 1,
    // 'lastchecktime': '2023-05-01 00:25:43',
    // 'lastchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastcheckoktime': '2023-05-01 00:25:43',
    // 'lastcheckoktime_iso8601': '2023-05-01T00:25:43Z',
    // 'lastlocalchecktime': '2023-05-01 00:25:43',
    // 'lastlocalchecktime_iso8601': '2023-05-01T00:25:43Z',
    // 'clicktimestamp': '2023-05-01 06:51:04',
    // 'clicktimestamp_iso8601': '2023-05-01T06:51:04Z',
    // 'clickcount': 492,
    // 'clicktrend': -15,
    // 'ssl_error': 0,
    // 'geo_lat': None,
    // 'geo_long': None,
    // 'has_extended_info': False}]
    String url = '/json/stations/search';
    Map<String, dynamic> queryParameters = HashMap();
    if (name != null) {
      queryParameters['name'] = name;
    }
    if (nameExact != null) {
      queryParameters['nameExact'] = nameExact ? 'true' : 'false';
    }
    if (country != null) {
      queryParameters['country'] = country;
    }
    if (countryExact != null) {
      queryParameters['countryExact'] = countryExact ? 'true' : 'false';
    }
    if (countrycode != null) {
      queryParameters['countrycode'] = countrycode;
    }
    if (state != null) {
      queryParameters['state'] = state;
    }
    if (stateExact != null) {
      queryParameters['stateExact'] = stateExact ? 'true' : 'false';
    }
    if (language != null) {
      queryParameters['language'] = language;
    }
    if (languageExact != null) {
      queryParameters['languageExact'] = languageExact ? 'true' : 'false';
    }
    if (tag != null) {
      queryParameters['tag'] = tag.toLowerCase();
    }
    if (tagExact != null) {
      queryParameters['tagExact'] = tagExact ? 'true' : 'false';
    }
    if (tagList != null) {
      queryParameters['tagList'] = tagList.toLowerCase();
    }
    if (bitrateMin != null) {
      queryParameters['bitrateMin'] = bitrateMin;
    }
    if (bitrateMax != null) {
      queryParameters['bitrateMax'] = bitrateMax;
    }
    if (order != null) {
      queryParameters['order'] = order;
    }
    if (reverse != null) {
      queryParameters['reverse'] = reverse;
    }
    if (offset != null) {
      queryParameters['offset'] = offset;
    }
    if (limit != null) {
      queryParameters['limit'] = limit;
    }
    if (hidebroken != null) {
      queryParameters['hidebroken'] = hidebroken ? 'true' : 'false';
    }
    Response response = await dio.get(url, queryParameters: queryParameters);
    return response.data;
  }
}
