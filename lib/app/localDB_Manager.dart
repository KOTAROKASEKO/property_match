//==============================================================
//It will delete the local database data when the user logs out.
//==============================================================

import 'package:re_conver/common_feature/chat/repo/isar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> deleteAllData()async{
  IsarService _isarService = IsarService();
  await _isarService.clearDatabaseOnLogout();
  await SharedPreferences.getInstance().then((prefs) {
    prefs.clear();
  });
}