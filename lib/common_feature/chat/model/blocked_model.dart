import 'package:isar/isar.dart';

part 'blocked_model.g.dart';

@collection
class BlockedUsersModel {
  Id id = Isar.autoIncrement;

  List<String> blockedUsers = [];
}
