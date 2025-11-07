// lib/app/localDB_Manager.dart
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:template_hive/template_hive.dart';
import '../3-shared/common_feature/repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_data/shared_data.dart';

Future<bool> deleteAllData() async {
  try {
    ChatRepository chatRepo = getChatRepository();
    await chatRepo.clearDatabaseOnLogout();

    final boxNames = [
      propertyTemplateBox,
      agentTemplateMessageBoxName,
      tenanTemplateMessageBoxName,
    ];

    for (final boxName in boxNames) {
      if (Hive.isBoxOpen(boxName)) {
        pr('deleteAllData: Box $boxName is open. Clearing and closing...');

        if (boxName == propertyTemplateBox) {
          final box = Hive.box<PropertyTemplate>(boxName);
          await box.clear();
          await box.close();
        } else {
          final box = Hive.box<TemplateModel>(boxName);
          await box.clear();
          await box.close();
        }

        pr('Box $boxName cleared and closed.');
      } else {
        pr('deleteAllData: Box $boxName was already closed.');
      }

      await Hive.deleteBoxFromDisk(boxName);
      pr('deleteAllData: Successfully deleted box from disk: $boxName');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    pr('✅ SharedPreferences cleared.');
    pr('All local data successfully deleted.');
    return true;
  } catch (e) {
    pr('❌ Error deleting local data: $e');
    return false;
  }
}

