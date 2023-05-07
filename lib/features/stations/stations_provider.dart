import 'dart:async';

import 'package:dio/dio.dart';

import '../../shared/model/mem_station.dart';
import 'model/Top500Legacy.dart';
import 'model/remote_stations_model.dart';

const _stationNumber = 10;
const _api = 'https://api.shoutcast.com';

const _entryPoint = "https://yp.shoutcast.com";
const _apiKey = 'AG3OkhptMLcfExTH';

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
    // TODO: implementme
    /**
    final url = '$_entryPoint${el.listenurl}?id=${el.id}';
    try {
      final response = await dio.get<dynamic>(url);
      el.metadata = StationMetadata.fromXmlElement(response.data!);
      el.state = ((el.metadata?.container?.trackList ?? []).isNotEmpty) ? TuneState.resolved : TuneState.invalid;
    } catch (err) {
      el.errorMessage = 'Caught error: $err';
      el.state = TuneState.invalid;
    }
     * 
     */
  }
}
