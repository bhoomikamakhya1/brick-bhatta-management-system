// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'labour_work_model.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class LabourWorkAdapter extends TypeAdapter<LabourWork> {
//   @override
//   final int typeId = 1;
//
//   @override
//   LabourWork read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return LabourWork(
//       id: fields[0] as String,
//       labourName: fields[1] as String,
//       labourCategory: fields[2] as String,
//       quantity: fields[3] as double,
//       percentage: fields[4] as double?,
//       rate: fields[5] as double,
//       totalAmount: fields[6] as double,
//       date: fields[7] as DateTime,
//       synced: fields[8] as bool,
//       serverId: fields[9] as String?,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, LabourWork obj) {
//     writer
//       ..writeByte(10)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.labourName)
//       ..writeByte(2)
//       ..write(obj.labourCategory)
//       ..writeByte(3)
//       ..write(obj.quantity)
//       ..writeByte(4)
//       ..write(obj.percentage)
//       ..writeByte(5)
//       ..write(obj.rate)
//       ..writeByte(6)
//       ..write(obj.totalAmount)
//       ..writeByte(7)
//       ..write(obj.date)
//       ..writeByte(8)
//       ..write(obj.synced)
//       ..writeByte(9)
//       ..write(obj.serverId);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is LabourWorkAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
