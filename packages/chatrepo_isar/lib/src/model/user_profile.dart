import 'package:isar/isar.dart';

part 'user_profile.g.dart'; // Remember to re-run build_runner for this file

@Collection()
class UserProfileForChat { // Renamed from UserProfile
  @Index(unique: true, replace: true)
  late String userId;

  Id get isarId => fastHash(userId);

  String? displayName;
  String? profileImageUrl;
  late DateTime lastFetched;

  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      hash ^= string.codeUnitAt(i++); 
      hash *= 0x100000001b3;
    }
    return hash;
  }
}