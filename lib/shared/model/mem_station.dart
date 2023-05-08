import 'package:flutter/widgets.dart';

enum TuneState { init, resolved, invalid }

class MemStation {
  final int id;
  final String name;
  final String listenurl;
  final String metadataurl;
  ValueNotifier<StationMetadata> metadata = ValueNotifier<StationMetadata>(StationMetadata(0, ''));

  var state = TuneState.init;
  var errorMessage = '';

  MemStation({required this.id, required this.name, required this.listenurl, required this.metadataurl});

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

class StationMetadata {
  final int uniquelisteners;
  final String songtitle;
  StationMetadata(this.uniquelisteners, this.songtitle);
}
