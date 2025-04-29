// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Phone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhoneAdapter extends TypeAdapter<Phone> {
  @override
  final int typeId = 1;

  @override
  Phone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phone(
      phoneId: fields[0] as int,
      phoneNumber: fields[1] as String,
      type: fields[2] as PhoneType,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Phone obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.phoneId)
      ..writeByte(1)
      ..write(obj.phoneNumber)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhoneTypeAdapter extends TypeAdapter<PhoneType> {
  @override
  final int typeId = 2;

  @override
  PhoneType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PhoneType.UNKNOWN;
      case 1:
        return PhoneType.SAFE;
      case 2:
        return PhoneType.SPAM;
      default:
        return PhoneType.UNKNOWN;
    }
  }

  @override
  void write(BinaryWriter writer, PhoneType obj) {
    switch (obj) {
      case PhoneType.UNKNOWN:
        writer.writeByte(0);
        break;
      case PhoneType.SAFE:
        writer.writeByte(1);
        break;
      case PhoneType.SPAM:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
