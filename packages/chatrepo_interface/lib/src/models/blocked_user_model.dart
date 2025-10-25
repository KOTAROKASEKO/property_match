import 'package:isar/isar.dart';

class BlockedUsersModel {
  Id id = Isar.autoIncrement;

  List<String> blockedUsers = [];
}
