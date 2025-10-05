// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyTemplateAdapter extends TypeAdapter<PropertyTemplate> {
  @override
  final int typeId = 12;

  @override
  PropertyTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyTemplate(
      rent: fields[0] as double,
      name: fields[1] as String,
      photoUrls: (fields[2] as List).cast<String>(),
      location: fields[3] as String,
      description: fields[4] as String,
      gender: fields[5] as String,
      nationality: fields[6] as String,
      roomType: fields[7] as String,
      // ★★★ ここを修正 ★★★
      // fields[8] が null の場合は空文字列 '' を使うように変更
      postId: fields[8] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, PropertyTemplate obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.rent)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.photoUrls)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.nationality)
      ..writeByte(7)
      ..write(obj.roomType)
      ..writeByte(8)
      ..write(obj.postId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}