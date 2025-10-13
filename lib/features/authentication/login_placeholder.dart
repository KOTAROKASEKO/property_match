import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/features/authentication/register_screen.dart';
import 'package:re_conver/features/authentication/role_selection_screen.dart';
import 'package:re_conver/features/authentication/userdata.dart';
import 'package:re_conver/service/FirebaseApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A modern, clean login screen that integrates Firebase authentication logic.
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

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the sign-in process with email and password.
  Future<void> _signInWithEmailAndPassword() async {
    // Validate the form before proceeding.
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSigningIn = true);
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        if (userCredential.user != null) {
          // Centralized navigation logic after successful sign-in.
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

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            "965355667703-7md7nnua0qk4jafafle96rqqc9v7sukv.apps.googleusercontent.com",
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        pr('Google Login success');
            await _navigateAfterSignIn(userCredential.user!);
        }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      }
    } catch (error) {
      // This will catch the Google Sign in exception
      if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) {
        // User canceled the sign-in process, do nothing.
        return null;
      }
      // For any other errors, show a generic message.
      print("Error during Google Sign-In: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during sign in.')),
        );
      }
      return null;
    }
    return null;
  }

  Future<void> _navigateAfterSignIn(User user) async {
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
      // Handles new users or existing users without a role.
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
            // Form widget for input validation.
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                    onPressed: _isSigningIn
                        ? null
                        : _signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    // Show a loading indicator when signing in.
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
                  OutlinedButton.icon(
                    onPressed: _isSigningIn ? null : _signInWithGoogle,
                    icon: SvgPicture.string(_googleIconSvg, height: 20.0),
                    label: const Text(
                      'Sign In with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

  // Helper method to build styled text fields.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      // Changed to TextFormField for validation
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

  // Helper method for the "OR" divider.
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

// Inline SVG data for the Google logo.
const String _googleIconSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 488 512"><path d="M488 261.8C488 403.3 381.5 512 244 512 111.8 512 0 398.2 0 256S111.8 0 244 0c69.8 0 130.8 28.2 175.2 72.9l-65.7 64.4C333.9 116.1 292.8 96 244 96c-82.6 0-149.2 67.5-149.2 150.8s66.6 150.8 149.2 150.8c97.1 0 130.2-72.2 134.5-108.8H244v-85.3h236.1c2.3 12.7 3.9 26.9 3.9 41.4z"/></svg>';
