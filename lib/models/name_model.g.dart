// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NameModelAdapter extends TypeAdapter<NameModel> {
  @override
  final int typeId = 0;

  @override
  NameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NameModel(
      displayName: fields[0] as String,
      group: fields[1] as String,
      phone: fields[2] as String?,
      gstin: fields[3] as String?,
      commissionPercent: fields[4] as double?,
      synced: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
      serverId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NameModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.group)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.gstin)
      ..writeByte(4)
      ..write(obj.commissionPercent)
      ..writeByte(5)
      ..write(obj.synced)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.serverId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
