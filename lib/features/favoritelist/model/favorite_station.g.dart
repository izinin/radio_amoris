// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_station.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteStationAdapter extends TypeAdapter<FavoriteStation> {
  @override
  final int typeId = 0;

  @override
  FavoriteStation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteStation(
      id: fields[0] as int,
      name: fields[1] as String,
      logo: fields[2] as String,
      url: fields[3] as String,
      assetlogo: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteStation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.assetlogo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteStationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
