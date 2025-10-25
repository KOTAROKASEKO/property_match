// lib/app/localDB_Manager.dart
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../3-shared/common_feature/chat/data/repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_data/shared_data.dart';

Future<void> deleteAllData() async {
  pr('Starting local data deletion for logout...');
  try {
    // 1. Clear Isar Database
    ChatRepository chatRepo = getChatRepository();
    await chatRepo.clearDatabaseOnLogout();
    pr('✅ Isar database cleared.');

    // 2. Close all Hive boxes before deleting them
    await Hive.close();
    pr('✅ All Hive boxes closed.');

    // 3. Delete Hive box files from disk
    final boxNames = [
      agentTemplateMessageBoxName,
      tenanTemplateMessageBoxName,
      propertyTemplateBox,
    ];

    for (final boxName in boxNames) {
      await Hive.deleteBoxFromDisk(boxName);
      pr('✅ Hive box "$boxName" deleted from disk.');
    }

    // 4. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    pr('✅ SharedPreferences cleared.');

    pr('All local data successfully deleted.');

  } catch (e) {
    pr('❌ Error deleting local data: $e');
    // Optionally, rethrow the exception if the caller needs to handle it
    // rethrow;
  }
}