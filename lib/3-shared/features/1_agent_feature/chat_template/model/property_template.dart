import 'package:hive/hive.dart';

part 'property_template.g.dart';

@HiveType(typeId: 12)
class PropertyTemplate extends HiveObject {
  @HiveField(0)
  double rent;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> photoUrls;

  @HiveField(3)
  String location;

  @HiveField(4)
  String description;

  @HiveField(5)
  String gender;

  @HiveField(6)
  String nationality;

  @HiveField(7)
  String roomType;

  @HiveField(8)
  String postId;

  PropertyTemplate({
    required this.rent,
    required this.name,
    required this.photoUrls,
    required this.location,
    required this.description,
    this.gender = 'Mix',
    this.nationality = 'Any',
    required this.roomType,
    required this.postId,
  });
}