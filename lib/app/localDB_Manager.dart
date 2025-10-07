//==============================================================
//It will delete the local database data when the user logs out.
//==============================================================

import 'package:hive/hive.dart';
import 'package:re_conver/common_feature/chat/repo/isar_helper.dart';
import 'package:re_conver/features/authentication/userdata.dart';
import 'package:re_conver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> deleteAllData()async{
  ChatDatabase _isarService = ChatDatabase();
  await _isarService.clearDatabaseOnLogout();
  if(userData.role==Roles.agent){
    Hive.deleteBoxFromDisk(agentTemplateMessageBoxName); 
  }else{
    Hive.deleteBoxFromDisk(tenanTemplateMessageBoxName);
  }
  
  await SharedPreferences.getInstance().then((prefs) {
    prefs.clear();
  });
}