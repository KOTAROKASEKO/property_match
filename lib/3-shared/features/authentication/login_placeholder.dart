// lib/features/authentication/login_placeholder.dart (Web専用クリーンアップ版)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart'; // <-- 削除 (kIsWebを使わないため)
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_data/shared_data.dart';
import '../../MainScaffold.dart';
import 'register_screen.dart';
import 'role_selection_screen.dart';
import 'widgets/sign_in_button_web.dart';
// 'widgets/sing_in_button.dart' (条件付き) ではなく、
// 'widgets/sign_in_button.dart' (Web専用) を直接インポート
import '../../service/FirebaseApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPlaceholderScreen extends StatefulWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  State<LoginPlaceholderScreen> createState() => _LoginPlaceholderScreenState();
}

class _LoginPlaceholderScreenState extends State<LoginPlaceholderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  /// GoogleSignInを初期化し、認証ストリームのリスナーを設定
  Future<void> _initializeGoogleSignIn() async {
    try {
      // v7.x で必須となった initialize を呼び出す
      // Web専用なので kIsWeb 分岐を削除
      await GoogleSignIn.instance.initialize(
        clientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
        // serverClientId: null, // Webでは不要なので null のまま
      );

      // authenticationEvents を使用
      _authSubscription = GoogleSignIn.instance.authenticationEvents
          .listen((GoogleSignInAuthenticationEvent event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          if (mounted && !_isSigningIn) {
            setState(() => _isSigningIn = true);
          }

          final GoogleSignInAccount account = event.user;
          try {
            final String? idToken = account.authentication.idToken;
            final authClient = account.authorizationClient;
            final GoogleSignInClientAuthorization? clientAuth =
                await authClient.authorizeScopes(['email']);
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

            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            if (userCredential.user != null) {
              await _navigateAfterSignIn(userCredential.user!);
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  /// メール/パスワードでのサインイン
  Future<void> _signInWithEmailAndPassword() async {
    // (この関数は変更なし)
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSigningIn = true);
      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await _navigateAfterSignIn(userCredential.user!);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'An error occurred')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSigningIn = false);
        }
      }
    }
  }

  Future<void> _navigateAfterSignIn(User user) async {
    // (この関数は変更なし)
    if (!mounted) return;

    userData.setUser(user);
    await saveTokenToDatabase();

    final navigator = Navigator.of(context);
    final userDoc = await FirebaseFirestore.instance
        .collection('users_prof')
        .doc(user.uid)
        .get();

    if (userDoc.exists &&
        userDoc.data() != null &&
        userDoc.data()!.containsKey('role')) {
      final role = userDoc.data()!['role'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role);

      userData.setRole(role == 'agent' ? Roles.agent : Roles.tenant);
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
        (route) => false,
      );
    } else {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ... (Lottie, Welcome, Email, Password, Sign In Button... 変更なし) ...
                  SizedBox(
                    height: 120,
                    child: Lottie.asset('assets/home.json'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'fancy',
                    ),
                  ),
                  const Text(
                    'Bilik Match',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'fancy',
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email Text Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Text Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSigningIn
                          ? null
                          : () {
                              // TODO: Implement forgot password functionality.
                            },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  ElevatedButton(
                    onPressed:
                        _isSigningIn ? null : _signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isSigningIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  _buildDivider(),
                  const SizedBox(height: 24),

                  // Google Sign In Button
                  // _isSigningIn が true の場合、スピナーを表示
                  // false の場合のみ、Google サインインボタンを表示
                  _isSigningIn
                      ? const Center(child: CircularProgressIndicator())
                      : SignInButton(
                          // onPressed: _signInWithGoogle, // <-- 削除
                          isSigningIn: _isSigningIn, // <-- ボタン側では使わないが念の為残す
                        ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _isSigningIn
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (_buildTextField と _buildDivider ヘルパーメソッドは変更なし) ...
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}