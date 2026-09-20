
part of 'program_model.dart';

class ProgramModelAdapter extends TypeAdapter<ProgramModel> {
  @override
  final int typeId = 0;

  @override
  ProgramModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as String,
      duration: fields[4] as int,
      universityId: fields[5] as String,
      isActive: fields[6] as bool,
      dimensions: (fields[7] as Map?)?.cast<String, double>(),
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.universityId)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.dimensions)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

