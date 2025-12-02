// lib/3-shared/features/authentication/sign_in_modal.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:re_conver/3-shared/features/authentication/login_placeholder.dart';
import 'package:re_conver/3-shared/features/authentication/sign_in_button_stub.dart'; // Cross-platform button

class SignInModal extends StatefulWidget {
  const SignInModal({super.key});

  @override
  State<SignInModal> createState() => _SignInModalState();
}

class _SignInModalState extends State<SignInModal> {
  bool _isSigningIn = false;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Only initialize Web GIS SDK and listener on Web
    if (kIsWeb) {
      _initializeGoogleSignInWeb();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Web: Google Sign-In Initialization & Event Listener (GIS Flow)
  Future<void> _initializeGoogleSignInWeb() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      _authSubscription = GoogleSignIn.instance.authenticationEvents
          .listen((GoogleSignInAuthenticationEvent event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          if (mounted && !_isSigningIn) {
            setState(() => _isSigningIn = true);
          }
          final GoogleSignInAccount account = event.user;
          try {
            // 1. Get authentication
            final GoogleSignInAuthentication googleAuth =
                await account.authentication;

            // 2. Get ID token
            final String? idToken = googleAuth.idToken;

            if (idToken == null) {
              throw 'Failed to get id token from Google.';
            }

            // 3. Create credential (accessToken is null for Web GIS flow)
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: null,
              idToken: idToken,
            );

            // 4. Sign in to Firebase
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            if (userCredential.user != null && mounted) {
              Navigator.pop(context, true);
            }
          } catch (error) {
            print("Error during auth event processing: $error");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign in Error: $error')),
              );
            }
            await GoogleSignIn.instance.signOut();
          } finally {
            if (mounted) {
              setState(() => _isSigningIn = false);
            }
          }
        }
      }, onError: (error) {
        print("Auth Stream Error: $error");
        if (mounted) {
          setState(() => _isSigningIn = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in Error: $error')),
          );
        }
      });
    } catch (error) {
      print("Error initializing Google Sign-In: $error");
    }
  }

  /// Mobile: Native Google Sign-In (App implementation)
  Future<void> _signInWithGoogleMobile() async {
    setState(() {
      _isSigningIn = true;
    });
    try {
      // 1. Initialize (Required for this specific implementation)
      await GoogleSignIn.instance.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      );

      // 2. Authenticate using the 'authenticate' method as found in login_placeholder.dart
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        // User canceled
        setState(() {
          _isSigningIn = false;
        });
        return;
      }

      // 3. Retrieve tokens using the specific properties from login_placeholder.dart
      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      final authClient = googleUser.authorizationClient;
      final GoogleSignInClientAuthorization? clientAuth =
          await authClient.authorizeScopes(['email']);
      final String? accessToken = clientAuth?.accessToken;

      if (accessToken == null) {
        throw 'Failed to get access token from Google.';
      }
      if (idToken == null) {
        throw 'Failed to get id token from Google.';
      }

      // 4. Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 5. Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
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

            // Lottie Animation
            SizedBox(
              height: 150,
              width: 150,
              child: Lottie.asset(
                'assets/signin_dog.json',
              ),
            ),
            const SizedBox(height: 20),

            if (_isSigningIn)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: [
                  // Cross-platform button
                  // Mobile: uses sign_in_button_mobile.dart and executes onPressed
                  // Web: uses sign_in_button_web.dart (GIS button), ignores onPressed
                  SignInButton(
                    isSigningIn: _isSigningIn,
                    onPressed: _signInWithGoogleMobile,
                  ),
                  const SizedBox(height: 12),
                  // Email Sign In Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
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
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}