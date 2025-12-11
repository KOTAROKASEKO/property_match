// lib/3-shared/features/2_tenant_feature/3_profile/view/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold( 
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.person),
            SizedBox(width: 10,),
            Text('My Profile', style: TextStyle(color: Colors.white),),
            ]),
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
                _buildProfileHeader(userProfile),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark_border, color: Colors.deepPurple),
                    title: const Text('Saved Listings', style: TextStyle(fontWeight: FontWeight.w500)),
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
                _buildProfileDetailsCard(userProfile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile userProfile) {
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
        // Display the user's display name
        Text(
          userProfile.displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Display the user's email
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
                builder: (context) => EditProfileScreen(skipOption: 'Save',userProfile: userProfile,isNewUser: false,),
              ),
            );
            // If the profile was updated, refresh the data
            if (result == true) {
              _loadUserProfile();
            }
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
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

  Widget _buildProfileDetailsCard(UserProfile userProfile) {
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
                'Personal Info',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.deepPurple.shade700
                ),
              ),
            ),
            _ProfileDetailRow(
              icon: Icons.cake_outlined,
              title: 'Age',
              value: '${userProfile.age} years old',
            ),
            _ProfileDetailRow(
              icon: Icons.person_outline,
              title: 'Gender',
              value: userProfile.gender,
            ),
            _ProfileDetailRow(
              icon: Icons.flag_outlined,
              title: 'Nationality',
              value: userProfile.nationality,
            ),
            _ProfileDetailRow(
              icon: Icons.work_outline,
              title: 'Occupation',
              value: userProfile.occupation,
            ),
            _ProfileDetailRow(
              icon: Icons.location_city_outlined,
              title: 'Work/Study Location',
              value: userProfile.location,
            ),
            if (userProfile.selfIntroduction.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.description_outlined,
                title: 'About Me',
                value: userProfile.selfIntroduction,
              ),
            if (userProfile.hobbies.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.interests_outlined,
                title: 'Hobbies',
                value: userProfile.hobbies.join(', '),
              ),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // --- Preferences Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.deepPurple.shade700
                ),
              ),
            ),
            _ProfileDetailRow(
              icon: Icons.calendar_today_outlined,
              title: 'Move-in Date',
              value: userProfile.moveinDate == null
                  ? 'Not specified'
                  : DateFormat.yMMMd().format(userProfile.moveinDate!),
            ),
            if (userProfile.preferredAreas.isNotEmpty)
              _ProfileDetailRow(
                icon: Icons.map_outlined,
                title: 'Preferred Areas',
                value: userProfile.preferredAreas.join(', '),
              ),
            _ProfileDetailRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget',
              value: 'RM ${userProfile.budget.toStringAsFixed(0)} / month',
            ),
            _ProfileDetailRow(
              icon: Icons.group_outlined,
              title: 'Number of Pax',
              value: '${userProfile.pax} person(s)',
            ),
            _ProfileDetailRow(
              icon: Icons.bed_outlined,
              title: 'Room Preference',
              value: userProfile.roomType,
            ),
            _ProfileDetailRow(
              icon: Icons.apartment_outlined,
              title: 'Property Preference',
              value: userProfile.propertyType,
            ),
            _ProfileDetailRow(
              icon: Icons.pets_outlined,
              title: 'Pets',
              value: userProfile.pets,
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
                  label: const Text(
                    'Logout',
                    style: TextStyle(
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
                  value.isEmpty ? 'Not specified' : value,
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