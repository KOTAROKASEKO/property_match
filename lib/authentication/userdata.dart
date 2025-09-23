import 'package:firebase_auth/firebase_auth.dart';

enum Roles {
  agent,
  tenant
}

class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  String _userId = "";
  Roles _role = Roles.tenant;

  String get userId => _userId;
  Roles get role => _role;

  void setUser(User? user) {
    _userId = user?.uid ?? "";
  }

  void setRole(Roles newRole) {
    _role = newRole;
    print("User role set to: $_role");
  }

  void clearUser() {
    _userId = "";
    _role = Roles.tenant;
  }
}

final userData = UserData();