import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:radioamoris/features/stations/index.dart';

import '../../appdata.dart';
import '../../shared/model/mem_station.dart';
import 'model/Top500Legacy.dart';
import 'model/remote_stations_model.dart';

class StationsRepository {
  final StationsProvider _stationsProvider = StationsProvider(Dio());

  List<MemStation>? get data {
    return AppData.inMemoryStations;
  }

  Future<void> getRemoteData() async {
    RemoteStationsModel model = await _stationsProvider.loadAsync();
    if (model.response.statusCode != 200) {
      throw Exception(model.response.statusText.isEmpty ? 'data error' : model.response.statusText);
    }
    AppData.inMemoryStations = model.response.data.stationlist.station!.where((e) => e.name.trim().isNotEmpty).map((e) {
      final asset = GetIt.I.get<AppData>().getDefaultArt();
      return MemStation(id: e.id, name: e.name, logo: e.logo ?? '', tunein: model.response.data.stationlist.tunein.baseXspf, assetlogo: asset);
    }).toList();
  }

  Future<void> getTop500RemoteData() async {
    Top500Legacy model = await _stationsProvider.loadTop500Async();
    AppData.inMemoryStations = model.stations!
        .where((e) => e.name != null && e.name!.trim().isNotEmpty)
        .map((e) {
          if (e.id == null || e.name == null && model.tunein == null || model.tunein!.baseXspf == null) {
            return null;
          }
          final asset = GetIt.I.get<AppData>().getDefaultArt();
          return MemStation(id: int.parse(e.id!), name: e.name!, logo: e.logo ?? '', tunein: model.tunein!.baseXspf!, assetlogo: asset);
        })
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }

  Future<void> fillTuneData(MemStation el) async {
    await _stationsProvider.fillTuneData(el);
  }
}
