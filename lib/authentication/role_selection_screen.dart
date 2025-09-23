import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/authentication/userdata.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, Roles role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is somehow null
      return;
    }

    try {
      if (role == Roles.tenant) {
        await FirebaseFirestore.instance
            .collection('users_prof')
            .doc(user.uid)
            .set({
          'displayName': user.displayName ?? 'New User',
          'profileImageUrl': user.photoURL ?? '',
          'bio': '',
          'username':
              user.displayName?.replaceAll(' ', '').toLowerCase() ?? 'newuser',
        });
      } else {
        await FirebaseFirestore.instance
            .collection('agents_prof')
            .doc(user.uid)
            .set({
          'displayName': user.displayName ?? 'New Agent',
          'profileImageUrl': user.photoURL ?? '',
          'bio': '',
          'username':
              user.displayName?.replaceAll(' ', '').toLowerCase() ?? 'newagent',
        });
      }

      userData.setRole(role);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScaffold(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting role: $e')),
      );
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
                label: "I'm a Tenant",
                onPressed: () => _selectRole(context, Roles.tenant),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context,
                icon: Icons.real_estate_agent_outlined,
                label: "I'm an Agent",
                onPressed: () => _selectRole(context, Roles.agent),
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