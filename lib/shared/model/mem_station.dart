import 'package:myradio/features/favoritelist/model/favorite_station.dart';

import 'remote_tunein_data.dart';

enum TuneState { init, resolved, invalid }

class MemStation {
  final int id;
  final String name;
  final String? logo;
  final String tunein;
  var url = '';
  RemoteTuneinData? tuneinData;
  bool isBookmarked = false;
  var state = TuneState.init;
  var errorMessage = '';
  final String assetlogo;

  MemStation({required this.id, required this.name, this.logo, required this.tunein, required this.assetlogo});

  @override
  String toString() {
    return 'InmemoryStation(id: $id, name: $name, logo: $logo, tunein: $tunein, url: $url, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MemStation &&
        other.id == id &&
        other.name == name &&
        other.logo == logo &&
        other.tunein == tunein &&
        other.url == url &&
        other.assetlogo == assetlogo;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ logo.hashCode ^ tunein.hashCode ^ url.hashCode ^ assetlogo.hashCode;
  }

  FavoriteStation toFavoriteStation() {
    return FavoriteStation(id: id, name: name, logo: logo ?? '', url: url, assetlogo: assetlogo);
  }
}
