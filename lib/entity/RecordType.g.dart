// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RecordType.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordTypeAdapter extends TypeAdapter<RecordType> {
  @override
  final int typeId = 4;

  @override
  RecordType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordType.CALL;
      case 1:
        return RecordType.MISSED_CALL;
      default:
        return RecordType.CALL;
    }
  }

  @override
  void write(BinaryWriter writer, RecordType obj) {
    switch (obj) {
      case RecordType.CALL:
        writer.writeByte(0);
        break;
      case RecordType.MISSED_CALL:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
