// lib/3-shared/features/authentication/widgets/sign_in_button_mobile.dart
import 'package:flutter/material.dart';
// Add other necessary mobile imports

class SignInButton extends StatelessWidget {
  final bool isSigningIn;
  final VoidCallback onPressed; // Mobile needs the onPressed callback

  const SignInButton({
    super.key,
    required this.onPressed,
    required this.isSigningIn,
  });

  @override
  Widget build(BuildContext context) {
    if (isSigningIn) {
      return const Center(child: CircularProgressIndicator());
    }
    // Return your mobile Google Sign-In button widget here
    // Example:
    return ElevatedButton.icon(
      icon: Image.asset('assets/google_logo.png', height: 24), // Example logo
      label: const Text('Sign in with Google'),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Ensure you have the google_sign_in dependency in your main pubspec.yaml
// dependencies:
//   google_sign_in: ^6.2.1 # Or latest version
