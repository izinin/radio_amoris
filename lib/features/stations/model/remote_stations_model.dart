// To parse this JSON data, do
//
//     final randomStationsModel = randomStationsModelFromJson(jsonString);

import 'dart:convert';

RemoteStationsModel randomStationsModelFromJson(String str) =>
    RemoteStationsModel.fromJson(json.decode(str));

class RemoteStationsModel {
  RemoteStationsModel({
    required this.response,
  });

  Response response;

  factory RemoteStationsModel.fromJson(Map<String, dynamic> json) =>
      RemoteStationsModel(
        response: Response.fromJson(json["response"]),
      );
}

class Response {
  Response({
    required this.data,
    required this.statusText,
    required this.statusCode,
  });

  Data data;
  String statusText;
  int statusCode;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        data: Data.fromJson(json["data"]),
        statusText: json["statusText"],
        statusCode: json["statusCode"],
      );
}

class Data {
  Data({
    required this.stationlist,
  });

  Stationlist stationlist;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        stationlist: Stationlist.fromJson(json["stationlist"]),
      );
}

class Stationlist {
  Stationlist({
    this.station,
    required this.tunein,
  });

  List<Station>? station;
  Tunein tunein;

  factory Stationlist.fromJson(Map<String, dynamic> json) => Stationlist(
        station:
            List<Station>.from(json["station"].map((x) => Station.fromJson(x))),
        tunein: Tunein.fromJson(json["tunein"]),
      );
}

class Station {
  Station({
    required this.id,
    required this.name,
    this.br,
    this.ct,
    this.mt,
    this.lc,
    this.genre,
    this.logo,
    this.ml,
  });

  int id;
  String name;
  int? br;
  String? ct;
  String? mt;
  int? lc;
  String? genre;
  String? logo;
  int? ml;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        br: json["br"],
        ct: json["ct"],
        mt: json["mt"],
        lc: json["lc"],
        name: json["name"],
        genre: json["genre"],
        logo: json["logo"],
        id: json["id"],
        ml: json["ml"],
      );
}

class Tunein {
  Tunein({
    required this.baseM3U,
    required this.baseXspf,
    required this.base,
  });

  String baseM3U;
  String baseXspf;
  String base;

  factory Tunein.fromJson(Map<String, dynamic> json) => Tunein(
        baseM3U: json["base-m3u"],
        baseXspf: json["base-xspf"],
        base: json["base"],
      );
}
