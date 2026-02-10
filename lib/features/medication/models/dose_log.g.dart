// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseLogAdapter extends TypeAdapter<DoseLog> {
  @override
  final int typeId = 1;

  @override
  DoseLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseLog(
      medId: fields[0] as String,
      scheduledTime: fields[1] as DateTime,
      takenAt: fields[2] as DateTime?,
      isMissed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DoseLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.medId)
      ..writeByte(1)
      ..write(obj.scheduledTime)
      ..writeByte(2)
      ..write(obj.takenAt)
      ..writeByte(3)
      ..write(obj.isMissed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
