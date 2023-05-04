import 'dart:convert';

import 'package:hive_flutter/adapters.dart';
part 'favorite_station.g.dart';

@HiveType(typeId: 0)
class FavoriteStation {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String logo;
  @HiveField(3)
  final String url;
  @HiveField(4)
  final String assetlogo;

  FavoriteStation({required this.id, required this.name, required this.logo, required this.url, required this.assetlogo});

  Map<String, dynamic> _toJson() => {
        'id': id,
        'name': name,
        'logo': logo,
        'url': url,
        'assetlogo': assetlogo,
      };

  @override
  String toString() {
    return json.encode(_toJson());
  }
}
