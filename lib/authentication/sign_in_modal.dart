import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInModal extends StatefulWidget {
  const SignInModal({super.key});

  @override
  State<SignInModal> createState() => _SignInModalState();
}

class _SignInModalState extends State<SignInModal> {
  bool _isSigningIn = false;

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: "965355667703-7md7nnua0qk4jafafle96rqqc9v7sukv.apps.googleusercontent.com",
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        return null;
      }

      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      final authClient = googleUser.authorizationClient;
      final GoogleSignInClientAuthorization? clientAuth = await authClient.authorizeScopes(['email']);
      final String? accessToken = clientAuth?.accessToken;

      if (accessToken == null) {
        throw 'Failed to get access token from Google.';
      }
      if (idToken == null) {
        throw 'Failed to get id token from Google.';
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // The post-login handling is now managed by the logic in login_placeholder.dart
      // and the AuthWrapper in main.dart, so we don't need to duplicate it here.
      // We just need to pop the modal and let the authStateChanges stream handle the navigation.
      
      return userCredential;
    } catch (error) {
      print("Error during Google Sign-In: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Sign In to Continue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isSigningIn)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  setState(() {
                    _isSigningIn = true;
                  });
                  final userCredential = await _signInWithGoogle();
                  if (mounted) {
                    Navigator.pop(context, userCredential != null);
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
