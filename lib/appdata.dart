import 'config.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:radio_amoris/config.dart';
import 'dart:convert';

class AppData {
  static final AppData _appData = new AppData._internal();
  factory AppData() {
    return _appData;
  }

  AppData._internal();

  Config _config;

  Future<Config> fetchConfig() async {
    HttpClient client = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    final IOClient httpc = new IOClient(client);
    final url = 'http://anima.sknt.ru/settings.json';
    final response = await httpc.get(url, headers: {
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36'
    });
    if (response.statusCode == 200) {
      _config = Config.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return _config;
    } else {
      throw Exception('Failed to load channel info');
    }
  }

  getChannels() {
    return _config?.channels;
  }
}

final appData = AppData();
