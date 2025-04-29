// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PhoneRecord.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhoneRecordAdapter extends TypeAdapter<PhoneRecord> {
  @override
  final int typeId = 3;

  @override
  PhoneRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhoneRecord(
      fields[0] as int,
      fields[1] as Phone,
      fields[2] as RecordType,
      fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PhoneRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.recordId)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.isBlocked)
      ..writeByte(4)
      ..write(obj.detail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhoneRecordDetailAdapter extends TypeAdapter<PhoneRecordDetail> {
  @override
  final int typeId = 5;

  @override
  PhoneRecordDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhoneRecordDetail(
      seconds: fields[0] as int,
      time: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PhoneRecordDetail obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.seconds)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneRecordDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
