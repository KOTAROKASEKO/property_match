import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import 'package:shared_data/src/database_path.dart';
import '../../MainScaffold.dart';
import '../2_tenant_feature/3_profile/models/profile_model.dart';
import '../2_tenant_feature/3_profile/view/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String? displayName;
  const RoleSelectionScreen({super.key, this.displayName,});

  /// Displays a confirmation dialog before setting the user's role.
  Future<void> _confirmAndSelectRole(BuildContext context, Roles role) async {
    final roleString = role == Roles.agent ? 'Agent' : 'Tenant';

    final bool? shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Your Role'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.5),
              children: <TextSpan>[
                const TextSpan(text: 'Do you really wish to continue as a '),
                TextSpan(
                    text: '"$roleString"',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '?\n\n'),
                const TextSpan(
                    text: 'You cannot change this once you register.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // If the user tapped "Continue", proceed with setting the role.
    if (shouldContinue == true) {
      await _selectRole(context, role);
    }
  }

  /// Sets the user role in Firestore and SharedPreferences.
  Future<void> _selectRole(BuildContext context, Roles role) async {
    pr('role_selection_scren.dart / updating user role');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final roleString = role == Roles.agent ? 'agent' : 'tenant';

      final userProfileData = {
        'role': roleString,
        'displayName': user.displayName ??
            (role == Roles.agent ? 'New Agent' : 'New User'),
        'profileImageUrl': user.photoURL ?? '',
        'bio': '',
        'username': user.displayName?.replaceAll(' ', '').toLowerCase() ??
            (role == Roles.agent ? 'newagent' : 'newuser'),
      };

      await FirebaseFirestore.instance
          .collection('users_prof')
          .doc(user.uid)
          .set(userProfileData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(rolePath, roleString);

      userData.setRole(role);
      if (role == Roles.tenant) {
        // Create a new UserProfile object for the new tenant
        final newUserProfile = UserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'New User',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(userProfile: newUserProfile),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScaffold(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How will you be using our app?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              _buildRoleCard(
                context,
                icon: Icons.person_outline,
                label: "I want room",
                // Updated to call the confirmation dialog
                onPressed: () => _confirmAndSelectRole(context, Roles.tenant),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                icon: Icons.real_estate_agent_outlined,
                label: "I want roommate",
                // Updated to call the confirmation dialog
                onPressed: () => _confirmAndSelectRole(context, Roles.agent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(width: 24),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}