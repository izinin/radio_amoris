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
    final response = await dio.get<dynamic>(el.metadataurl);
    print(response);
  }
}
