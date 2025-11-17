import 'package:firebase_auth/firebase_auth.dart';
import 'debug_print.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Roles {
  agent,
  tenant
}

class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  //When it is null, I want the getter to return uid. so setting it null
  String? _userId;
  Roles _role = Roles.tenant;

  String get userId => _userId ?? _setAndGet();
  Roles get role => _role;

  void setUser(User? user) {
    _userId = user?.uid;
    
  }

  //In case the user id is not set, it will set and return the userId.
  String _setAndGet(){
    pr('[userData.dart] Because the User ID is null, re-setting the user Id again..');
    setUser(FirebaseAuth.instance.currentUser);
    if(FirebaseAuth.instance.currentUser != null){
      return FirebaseAuth.instance.currentUser!.uid;
    }else{
      return '';
    }
  }

  void setRole(Roles newRole){
    _role = newRole;
    pr("User role set to: $_role");
  }

  void setRoleInLocal(Roles newRole)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('role', newRole == Roles.agent ? 'agent':'tenat');
  }

  void clearUser() {
    _userId = "";
    _role = Roles.tenant;
  }
}

final userData = UserData();