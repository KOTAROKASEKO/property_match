import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:re_conver/MainScaffold.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/app/localDB_Manager.dart';
import 'package:re_conver/authentication/forgotpassword.dart';
import 'package:re_conver/authentication/role_selection_screen.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/service/FirebaseApi.dart';

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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userData.setUser(FirebaseAuth.instance.currentUser);
        saveTokenToDatabase();
        if (mounted) {
          // Navigate to role selection with right-to-left slide animation
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from right
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
              },
            ),
          );
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _registerWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await _createUserProfile(userCredential.user!, _displayNameController.text.trim());
          await saveTokenToDatabase();
          userData.setUser(FirebaseAuth.instance.currentUser);
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      } finally {
        if (mounted) {
          setState(() => _isRegistering = false);
        }
      }
    }
  }

  Future<void> _createUserProfile(User user, String displayName) async {
    final userRef = FirebaseFirestore.instance.collection('users_prof').doc(user.uid);
    await userRef.set({
      'displayName': displayName,
      'profileImageUrl': user.photoURL ?? '',
      'bio': '',
      'username': displayName.replaceAll(' ', '').toLowerCase(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Start your journey with us today!",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _displayNameController,
                  decoration: _buildInputDecoration('Display Name'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Please enter a display name' : null,
                ),
                const SizedBox(height: 16),
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
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isRegistering
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registerWithEmailAndPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Register', style: TextStyle(fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


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

      await saveTokenToDatabase();
      _handleLoginSuccess(userCredential.user);
      return userCredential;
    } catch (error) {
      print("Error during Google Sign-In: $error");
      return null;
    }
  }

  Future<void> _handleLoginSuccess(User? user) async {
    if (user == null) return;
    userData.setUser(user);
    final navigator = Navigator.of(context);

    // Check if user is new by looking for a profile in either collection
    final userDoc = await FirebaseFirestore.instance.collection('users_prof').doc(user.uid).get();
    final agentDoc = await FirebaseFirestore.instance.collection('agents_prof').doc(user.uid).get();

    if (!userDoc.exists && !agentDoc.exists) {
      // New user, navigate to RoleSelectionScreen
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        (route) => false,
      );
    } else {
      // Existing user, determine role from claims or document and navigate to MainScaffold
      if (agentDoc.exists) {
          userData.setRole(Roles.agent);
      } else {
          userData.setRole(Roles.tenant);
      }
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
        (route) => false,
      );
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
                    userData.setUser(FirebaseAuth.instance.currentUser);
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

class SignOutModal extends StatefulWidget {
  const SignOutModal({super.key});

  @override
  State<SignOutModal> createState() => _SignOutModalState();
}

class _SignOutModalState extends State<SignOutModal> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try{
                  await deleteAllData();
                  await GoogleSignIn.instance.disconnect();
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    userData.setUser(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign out successful.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                }catch(error){
                  pr('Error in logging out : ${error}');
                }
                
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}