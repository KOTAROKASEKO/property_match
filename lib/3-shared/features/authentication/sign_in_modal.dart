import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:re_conver/3-shared/features/authentication/login_placeholder.dart';

class SignInModal extends StatefulWidget {
  const SignInModal({super.key});

  @override
  State<SignInModal> createState() => _SignInModalState();
}

class _SignInModalState extends State<SignInModal> {
  bool _isSigningIn = false;

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
        if (serverClientId.isEmpty) {
          throw Exception('GOOGLE_SERVER_CLIENT_ID not found in .env');
        }

      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
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

      final userCredential;
      userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      return userCredential;
    } catch (error) {
      print("Error during Google Sign-In: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error : $error')),
      );
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

          // ★ 2. Riveの代わりにLottieアニメーションをここに追加
          SizedBox(
            height: 150, // アニメーションの高さ（適宜調整してください）
            width: 150,  // アニメーションの幅（適宜調整してください）
            child: Lottie.asset(
              'signin_dog.json',
            ),
          ),
          const SizedBox(height: 20), // アニメーションとボタンの間のスペース

          if (_isSigningIn)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            )
          else
            // ★ 3. ボタンを格納するColumn (変更なし)
            Column(
              children: [
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
                const SizedBox(height: 12),
                // ★ 4. Email Sign In Button (変更なし)
                ElevatedButton.icon(
                  onPressed: () {
                    // Pop this modal
                    Navigator.pop(context);
                    // Navigate to the LoginPlaceholderScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPlaceholderScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Sign in with Email'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple, // Differentiate style
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}}
