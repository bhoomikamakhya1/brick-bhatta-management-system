// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 5;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      nameHindi: fields[2] as String,
      role: fields[3] as String,
      roleHindi: fields[4] as String,
      isActive: fields[5] as bool,
      initials: fields[6] as String,
      contactPerson: fields[7] as String?,
      phoneNumber: fields[8] as String?,
      address: fields[9] as String?,
      partyType: fields[10] as String?,
      gstNumber: fields[11] as String?,
      openingBalance: fields[12] as double?,
      openingBalanceType: fields[13] as String?,
      creditLimit: fields[14] as double?,
      synced: fields[15] as bool,
      serverId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameHindi)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.roleHindi)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.initials)
      ..writeByte(7)
      ..write(obj.contactPerson)
      ..writeByte(8)
      ..write(obj.phoneNumber)
      ..writeByte(9)
      ..write(obj.address)
      ..writeByte(10)
      ..write(obj.partyType)
      ..writeByte(11)
      ..write(obj.gstNumber)
      ..writeByte(12)
      ..write(obj.openingBalance)
      ..writeByte(13)
      ..write(obj.openingBalanceType)
      ..writeByte(14)
      ..write(obj.creditLimit)
      ..writeByte(15)
      ..write(obj.synced)
      ..writeByte(16)
      ..write(obj.serverId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
