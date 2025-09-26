import 'package:hive/hive.dart';

part 'template_model.g.dart';

@HiveType(typeId: 0)
class TemplateModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String templateMessage;

  TemplateModel({
    required this.id,
    required this.templateMessage,
  });

  // Optional: convenience factory / toMap if you want
  Map<String, dynamic> toMap() => {
        'id': id,
        'templateMessage': templateMessage,
      };

  factory TemplateModel.fromMap(Map<String, dynamic> m) => TemplateModel(
        id: m['id'] as int,
        templateMessage: m['templateMessage'] as String,
      );
}
