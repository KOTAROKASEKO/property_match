import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/language_provider.dart'; // LanguageProviderのパスに合わせて調整してください

class LanguageSelector extends StatelessWidget {
  final Color dropdownColor;
  final Color iconColor;
  final Color textColor;

  const LanguageSelector({
    super.key,
    this.dropdownColor = Colors.white,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: languageProvider.locale,
        icon: Icon(Icons.language, color: iconColor),
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor, fontSize: 14),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            languageProvider.setLocale(newLocale);
          }
        },
        items: const [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('en', style: TextStyle(color: Colors.black),),
          ),
          DropdownMenuItem(
            value: Locale('ja'),
            child: Text('日', style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    );
  }
}