import 'dart:async';

import 'package:dio/dio.dart';

import '../../shared/model/mem_station.dart';
import '../../shared/model/remote_tunein_data.dart';
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
    final response = await dio.get<dynamic>('$_api/station/randomstations?k=$_apiKey&f=json&limit=$_stationNumber');
    final stations = RemoteStationsModel.fromJson(response.data!);
    return stations;
  }

  Future<Top500Legacy> loadTop500Async() async {
    final response = await dio.get<dynamic>('$_api/legacy/Top500?k=$_apiKey');
    if (response.statusCode != 200) {
      throw Exception("failed to to fetch remote data");
    }
    final top500 = Top500Legacy.fromXmlElement(response.data!);
    return top500;
  }

  fillTuneData(MemStation el) async {
    final url = '$_entryPoint${el.tunein}?id=${el.id}';
    try {
      final response = await dio.get<dynamic>(url);
      el.tuneinData = RemoteTuneinData.fromXmlElement(response.data!);
      el.state = ((el.tuneinData?.container?.trackList ?? []).isNotEmpty) ? TuneState.resolved : TuneState.invalid;
    } catch (err) {
      el.errorMessage = 'Caught error: $err';
      el.state = TuneState.invalid;
    }
  }
}
