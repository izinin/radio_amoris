
enum TuneState { init, resolved, invalid }

class MemStation {
  final int id;
  final String name;
  final String listenurl;
  StationMetadata? metadata;
  final String logo;
  final String assetlogo;

  var state = TuneState.init;
  var errorMessage = '';

  MemStation({required this.id, required this.name, required this.listenurl, required this.logo, required this.assetlogo});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MemStation && other.id == id && other.name == name && other.listenurl == listenurl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ listenurl.hashCode;
  }
}

class StationMetadata {}
