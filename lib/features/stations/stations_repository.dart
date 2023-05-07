import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:radioamoris/features/stations/index.dart';

import '../../appdata.dart';
import '../../shared/model/mem_station.dart';
import 'model/remote_stations_model.dart';

class StationsRepository {
  final StationsProvider _stationsProvider = StationsProvider(Dio());
  static int _channelCounter = 1;

  List<MemStation>? get data {
    return AppData.inMemoryStations;
  }

  Future<void> getRemoteData() async {
    RemoteStationsModel model = await _stationsProvider.loadAsync();
    AppData.inMemoryStations = model.channels.map((e) {
      final asset = GetIt.I.get<AppData>().getDefaultArt();
      return MemStation(id: _channelCounter++, name: e.name, logo: '', listenurl: e.listenurl, assetlogo: asset);
    }).toList();
  }

  //TODO:
  Future<void> fillMetadata(MemStation el) async {
    await _stationsProvider.fillTuneData(el);
  }
}
