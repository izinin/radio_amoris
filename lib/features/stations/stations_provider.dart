import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../shared/model/mem_station.dart';
import 'model/remote_stations_model.dart';

class StationsProvider {
  final Dio dio;
  StationsProvider(this.dio);

  Future<RemoteStationsModel> loadAsync() async {
    const url = 'https://amoris.sknt.ru/settings.json';
    final response = await dio.get<dynamic>(url);

    final stations = RemoteStationsModel.fromJson(response.data!);
    // final stations = RemoteStationsModel.fromJson(StationData);
    return stations;
  }

  fillTuneData(MemStation el) async {
    final response = await dio.get<String>(el.metadataurl);
    try {
      final extractedJson = extractValidJson(response.data!);
      int listeners = extractedJson['uniquelisteners'] as int;
      String songtitle = extractedJson['songtitle'] as String;
      el.metadata.value = StationMetadata(listeners, songtitle);
    } catch (e) {
      el.metadata.value = StationMetadata(0, 'Error extracting JSON: $e');
    }
  }

  Map<String, dynamic> extractValidJson(String input) {
    // Regular expression to match the JSON content within the string
    final RegExp jsonRegex = RegExp(r'\{[^\}]+\}');

    // Find the first match of the JSON content
    final jsonMatch = jsonRegex.firstMatch(input);

    // If a match is found, return the extracted JSON string
    if (jsonMatch != null) {
      final jsonString = jsonMatch.group(0)!;
      return jsonDecode(jsonString);
    } else {
      // If no match is found, handle the error appropriately
      throw Exception('Invalid JSON format in the input string');
    }
  }
}
