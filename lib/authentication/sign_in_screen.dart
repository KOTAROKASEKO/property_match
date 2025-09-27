// lib/authentication/auth_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/authentication/forgotpassword.dart';
import 'package:re_conver/authentication/register_screen.dart';
import 'package:re_conver/authentication/role_selection_screen.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/service/FirebaseApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A helper for consistent text field styling
InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSigningIn = true);
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          userData.setUser(userCredential.user);
          await saveTokenToDatabase();

          if (mounted) {
            final userDoc = await FirebaseFirestore.instance.collection('users_prof').doc(userCredential.user!.uid).get();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('checking your account data..')),
              );

            if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('role')) {
              final role = userDoc.data()!['role'] as String;
              
              // SharedPreferencesにロールを保存
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('storing role in local storage')),
              );
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('role', role);

              userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScaffold()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      } finally {
        if (mounted) {
          setState(() => _isSigningIn = false);
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Welcome Back!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue your journey.",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _buildInputDecoration('Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 24),
                _isSigningIn
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signInWithEmailAndPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Sign In', style: TextStyle(fontSize: 16)),
                      ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPassword())),
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: const Text("Register Now"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
