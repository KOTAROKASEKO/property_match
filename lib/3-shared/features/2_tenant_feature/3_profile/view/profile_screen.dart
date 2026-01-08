// lib/3-shared/features/2_tenant_feature/3_profile/view/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/l10n/app_localizations.dart'; // ★ Import
import '../models/profile_model.dart';
import '../services/user_service.dart';
import 'saved_posts_scen.dart';
import '../../../authentication/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = _userService.getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // ★ Localization取得

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 10),
            Text(l.common_myProfile, style: const TextStyle(color: Colors.white)), // ★ 修正
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('User profile not found.'));
          }

          final userProfile = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadUserProfile(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(context, userProfile, l), // ★ lを渡す
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_border, color: Colors.deepPurple),
                    title: Text(l.common_savedListings, style: const TextStyle(fontWeight: FontWeight.w500)), // ★ 修正
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavedPostsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileDetailsCard(context, userProfile, l), // ★ lを渡す
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile, AppLocalizations l) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: userProfile.profileImageUrl.isNotEmpty
              ? CachedNetworkImageProvider(userProfile.profileImageUrl)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          child: userProfile.profileImageUrl.isEmpty
              ? Text(
                  userProfile.displayName.isNotEmpty ? userProfile.displayName[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40, color: Colors.deepPurple.shade800),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  skipOption: l.common_save, // ★ 修正
                  userProfile: userProfile,
                  isNewUser: false,
                ),
              ),
            );
            if (result == true) {
              _loadUserProfile();
            }
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l.common_editProfile), // ★ 修正
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetailsCard(BuildContext context, UserProfile userProfile, AppLocalizations l) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Personal Info Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l.profile_personalInfo, // ★ 修正
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
              ),
            ),
            _ProfileDetailRow(
              icon: Icons.cake_outlined,
              title: 'Age', // 一般的なラベルは英語のままでも通じますが、必要なら "Age" もキー追加推奨
              value: l.placeholder_age(userProfile.age), // ★ 修正
            ),
            _ProfileDetailRow(
              icon: Icons.person_outline,
              title: l.discover_gender, // ★ 既存キーを使用
              value: _getLocalizedGender(userProfile.gender, l), // ★ ヘルパー関数で変換
            ),
            _ProfileDetailRow(
              icon: Icons.flag_outlined,
              title: l.tenantFilter_nationality, // ★ 既存キーを使用
              value: userProfile.nationality,
            ),
            _ProfileDetailRow(
              icon: Icons.work_outline,
              title: l.profile_occupation, // ★ 修正
              value: userProfile.occupation,
            ),
            _ProfileDetailRow(
              icon: Icons.location_city_outlined,
              title: l.profile_workLocation, // ★ 修正
              value: userProfile.location,
            ),
            if (userProfile.selfIntroduction.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.description_outlined,
                title: l.profile_aboutMe, // ★ 修正
                value: userProfile.selfIntroduction,
              ),
            if (userProfile.hobbies.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.interests_outlined,
                title: l.profile_hobbies, // ★ 修正
                value: userProfile.hobbies.join(', '),
              ),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // --- Preferences Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l.profile_preferences, // ★ 修正
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
              ),
            ),
            _ProfileDetailRow(
              icon: Icons.calendar_today_outlined,
              title: l.tenantFilter_moveInDate, // ★ 既存キー
              value: userProfile.moveinDate == null
                  ? l.profile_notSpecified // ★ 修正
                  : DateFormat.yMMMd().format(userProfile.moveinDate!),
            ),
            if (userProfile.preferredAreas.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.map_outlined,
                title: l.profile_preferredAreas, // ★ 修正
                value: userProfile.preferredAreas.join(', '),
              ),
            _ProfileDetailRow(
              icon: Icons.account_balance_wallet_outlined,
              title: l.profile_budget, // ★ 修正
              value: l.placeholder_rmPerMonth(userProfile.budget.toStringAsFixed(0)), // ★ 修正
            ),
            _ProfileDetailRow(
              icon: Icons.group_outlined,
              title: l.profile_numberOfPax, // ★ 修正
              value: l.profile_paxCount(userProfile.pax), // ★ 修正
            ),
            _ProfileDetailRow(
              icon: Icons.bed_outlined,
              title: l.profile_roomPreference, // ★ 修正
              value: _getLocalizedRoomType(userProfile.roomType, l), // ★ ヘルパー関数
            ),
            _ProfileDetailRow(
              icon: Icons.apartment_outlined,
              title: l.profile_propertyPreference, // ★ 修正
              value: _getLocalizedPropertyType(userProfile.propertyType, l), // ★ ヘルパー関数
            ),
            _ProfileDetailRow(
              icon: Icons.pets_outlined,
              title: l.profile_pets, // ★ 修正
              value: userProfile.pets == 'Yes' ? l.profile_yes : l.profile_no, // ★ 修正
              isLast: true,
            ),

            const Divider(indent: 16, endIndent: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await showSignOutModal(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    l.profile_logout, // ★ 修正
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods for Localizing Values
  String _getLocalizedGender(String gender, AppLocalizations l) {
    if (gender == 'Male') return l.tenantFilter_genderMale;
    if (gender == 'Female') return l.tenantFilter_genderFemale;
    if (gender == 'Mix') return l.tenantFilter_genderMix;
    return l.profile_notSpecified;
  }

  String _getLocalizedRoomType(String type, AppLocalizations l) {
    if (type == 'Single') return l.tenantFilter_roomSingle;
    if (type == 'Middle') return l.tenantFilter_roomMiddle;
    if (type == 'Master') return l.tenantFilter_roomMaster;
    if (type == 'Any') return l.profile_any;
    return type;
  }

  String _getLocalizedPropertyType(String type, AppLocalizations l) {
    if (type == 'Condominium') return l.propertyType_condo;
    if (type == 'Apartment') return l.propertyType_apartment;
    if (type == 'Landed House') return l.propertyType_landed;
    if (type == 'Studio') return l.propertyType_studio;
    return type;
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _ProfileDetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, isLast ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty || value == 'Not specified' ? 'Not specified' : value, // Note: "Not specified" is just fallback key here
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}