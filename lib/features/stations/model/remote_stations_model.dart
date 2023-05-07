import 'dart:convert';

//			"name": "Drum and Bass (160 kbps)",
//			"listenurl": "https://amoris.sknt.ru/dnb.mp3",
//			"metadata": "https://amoris.sknt.ru/dnb/stats.json"

RemoteStationsModel randomStationsModelFromJson(String str) => RemoteStationsModel.fromJson(json.decode(str));

class RemoteStationsModel {
  RemoteStationsModel({
    required this.channels,
  });

  List<ChannelDescriptor> channels;

  factory RemoteStationsModel.fromJson(Map<String, dynamic> json) => RemoteStationsModel(
        channels: (json["channels"] as List<dynamic>).map((e) => ChannelDescriptor.fromJson(e)).toList(),
      );
}

class ChannelDescriptor {
  ChannelDescriptor({
    required this.name,
    required this.listenurl,
    required this.metadata,
  });

  String name;
  String listenurl;
  String metadata;

  factory ChannelDescriptor.fromJson(Map<String, dynamic> json) => ChannelDescriptor(
        name: json["name"],
        listenurl: json["listenurl"],
        metadata: json["metadata"],
      );
}
