// common_feature/chat/view/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/app/language_provider.dart';
import 'blocked_users_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSettingsSection(context, 'Account', [
            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Navigate to profile editing screen
              },
            ),
            _buildSettingsItem(
              context,
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              onTap: () {
                // TODO: Navigate to privacy screen
              },
            ),
            Consumer<LanguageProvider>(
              builder: (context, provider, child) {
                return ListTile(
                  leading: const Icon(Icons.language, color: Colors.deepPurple),
                  title: const Text('Language'),
                  trailing: DropdownButton<Locale>(
                    value: provider.locale,
                    underline: const SizedBox(), // 下線を消す
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
                    ],
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        provider.setLocale(newLocale);
                      }
                    },
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 20),
          _buildSettingsSection(context, 'User Management', [
            _buildSettingsItem(
              context,
              icon: Icons.block,
              title: 'Blocked Users',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
