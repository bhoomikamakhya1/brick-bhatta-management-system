// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'sale_model.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class BrickEntryAdapter extends TypeAdapter<BrickEntry> {
//   @override
//   final int typeId = 2;
//
//   @override
//   BrickEntry read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return BrickEntry(
//       id: fields[0] as String?,
//       brickType: fields[1] as String,
//       quantity: fields[2] as double,
//       price: fields[3] as double,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, BrickEntry obj) {
//     writer
//       ..writeByte(4)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.brickType)
//       ..writeByte(2)
//       ..write(obj.quantity)
//       ..writeByte(3)
//       ..write(obj.price);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is BrickEntryAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
//
// class FreightDetailsAdapter extends TypeAdapter<FreightDetails> {
//   @override
//   final int typeId = 3;
//
//   @override
//   FreightDetails read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return FreightDetails(
//       type: fields[0] as String,
//       vehicleNumber: fields[1] as String?,
//       vehicleName: fields[2] as String?,
//       driverName: fields[3] as String?,
//       driverPhone: fields[4] as String?,
//       ratePer1000: fields[5] as double,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, FreightDetails obj) {
//     writer
//       ..writeByte(6)
//       ..writeByte(0)
//       ..write(obj.type)
//       ..writeByte(1)
//       ..write(obj.vehicleNumber)
//       ..writeByte(2)
//       ..write(obj.vehicleName)
//       ..writeByte(3)
//       ..write(obj.driverName)
//       ..writeByte(4)
//       ..write(obj.driverPhone)
//       ..writeByte(5)
//       ..write(obj.ratePer1000);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FreightDetailsAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
//
// class SaleEntryAdapter extends TypeAdapter<SaleEntry> {
//   @override
//   final int typeId = 4;
//
//   @override
//   SaleEntry read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return SaleEntry(
//       id: fields[0] as String?,
//       customerName: fields[1] as String,
//       customerNameHindi: fields[2] as String,
//       customerAddress: fields[3] as String?,
//       customerPhone: fields[4] as String?,
//       date: fields[5] as DateTime,
//       time: fields[6] as DateTime,
//       brickEntries: (fields[7] as List).cast<BrickEntry>(),
//       advancePayment: fields[8] as double,
//       freightDetails: fields[9] as FreightDetails?,
//       totalAmount: fields[10] as double,
//       finalAmount: fields[11] as double,
//       remarks: fields[12] as String?,
//       otp: fields[13] as String?,
//       createdBy: fields[14] as String,
//       synced: fields[15] as bool,
//       serverId: fields[16] as String?,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, SaleEntry obj) {
//     writer
//       ..writeByte(17)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.customerName)
//       ..writeByte(2)
//       ..write(obj.customerNameHindi)
//       ..writeByte(3)
//       ..write(obj.customerAddress)
//       ..writeByte(4)
//       ..write(obj.customerPhone)
//       ..writeByte(5)
//       ..write(obj.date)
//       ..writeByte(6)
//       ..write(obj.time)
//       ..writeByte(7)
//       ..write(obj.brickEntries)
//       ..writeByte(8)
//       ..write(obj.advancePayment)
//       ..writeByte(9)
//       ..write(obj.freightDetails)
//       ..writeByte(10)
//       ..write(obj.totalAmount)
//       ..writeByte(11)
//       ..write(obj.finalAmount)
//       ..writeByte(12)
//       ..write(obj.remarks)
//       ..writeByte(13)
//       ..write(obj.otp)
//       ..writeByte(14)
//       ..write(obj.createdBy)
//       ..writeByte(15)
//       ..write(obj.synced)
//       ..writeByte(16)
//       ..write(obj.serverId);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SaleEntryAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
