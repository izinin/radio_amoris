import 'dart:async';

import 'package:dio/dio.dart';

import '../../shared/model/mem_station.dart';
import 'model/remote_stations_model.dart';

class StationsProvider {
  final Dio dio;
  StationsProvider(this.dio);

  Future<RemoteStationsModel> loadAsync() async {
    const url = 'http://anima.sknt.ru/settings.json';
    final response = await dio.get<dynamic>(url);

    final stations = RemoteStationsModel.fromJson(response.data!);
    return stations;
  }

  fillTuneData(MemStation el) async {
    // NOTE: this call returns 404 error with user agent header
    const userAgent = 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36';
    final response = await dio.get<dynamic>(el.metadataurl, options: Options(headers: {'user-agent': userAgent}));
    el.metadata?.value = StationMetadata(response.data['uniquelisteners'], response.data['songtitle']);
  }
}
