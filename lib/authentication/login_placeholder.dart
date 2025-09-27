// lib/authentication/login_placeholder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/authentication/sign_in_screen.dart';
import 'package:re_conver/authentication/auth_service.dart';
import 'package:re_conver/authentication/role_selection_screen.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/service/FirebaseApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 100,
                color: Colors.deepPurple.shade200,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to the Conversation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to connect with others, share your experiences, and join the community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Continue with Email'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final signedIn = await showSignInModal(context);
                  print('User signed in attempt ${signedIn} and ${context.mounted}');

                  if (signedIn == true && context.mounted) {
                    print('User signed in successfully');
                    userData.setUser(FirebaseAuth.instance.currentUser);
                    final user = userData.userId;
                    final navigator = Navigator.of(context);

                    final userDoc = await FirebaseFirestore.instance.collection('users_prof').doc(user).get();
                    
                    if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('role')) {
                        final roleData = userDoc.data()!['role'] as String;

                        // SharedPreferencesにロールを保存
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('role', roleData);

                        userData.setRole(roleData == 'agent' ? Roles.agent : Roles.tenant);
                        await saveTokenToDatabase();
                        navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const MainScaffold()),
                            (route) => false,
                        );
                    } else {
                        // This case handles both new users and existing users without a role
                        await saveTokenToDatabase();
                        navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                            (route) => false,
                        );
                    }
                  }
                },
                icon: const Icon(Icons.login), 
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}