// lib/features/authentication/login_placeholder.dart
// 他のimportの下に追加
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:re_conver/3-shared/features/authentication/forgotpassword.dart';
import 'package:re_conver/main.dart';
import 'sign_in_button_stub.dart';
import 'package:shared_data/shared_data.dart';
import 'role_selection_screen.dart';
import '../../service/FirebaseApi.dart';

class LoginPlaceholderScreen extends StatefulWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  State<LoginPlaceholderScreen> createState() => _LoginPlaceholderScreenState();
}

class _LoginPlaceholderScreenState extends State<LoginPlaceholderScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>(); // Sign Upフォーム用

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _registerDisplayNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isSigningIn = false;
  bool _isRegistering = false; // Sign Up処理中フラグ
  bool _showSignIn = true; // アニメーション切り替え用

  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  /// GoogleSignInを初期化し、認証ストリームのリスナーを設定
  Future<void> _initializeGoogleSignIn() async {
    try {
      pr('web google auth init');
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
    _registerDisplayNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<UserCredential?> _signInWithGoogleMobile() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      );
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        return null;
      }

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

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (error) {
      print("Error during Google Sign-In: $error");
      return null;
    }
  }

  /// メール/パスワードでのサインイン
  Future<void> _signInWithEmailAndPassword() async {
    if (_signInFormKey.currentState?.validate() ?? false) {
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

  // --- register_screen.dart からロジックをコピー ---
  Future<void> _registerWithEmailAndPassword() async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      try {
        pr('login_placeholder.dart user creation init');
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text.trim(),
        );
        pr('login_placeholder.dart user was created');
        if (userCredential.user != null) {
          await _createUserProfile(
              userCredential.user!, _registerDisplayNameController.text.trim());
        pr('login_placeholder.dart user collection was created');
          userData.setUser(userCredential.user);
          pr('login_placeholder.dart user state was set');
          saveTokenToDatabase();
          if (mounted) {
            pr('login_placeholder.dart build was mounted');
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => RoleSelectionScreen(
                        displayName: _registerDisplayNameController.text)),
                (route) => false);
          }else{
            pr('login_placeholder.dart build was unmounted. cannot navigate');
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

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _createUserProfile(User user, String displayName) async {
    final userRef =
        FirebaseFirestore.instance.collection('users_prof').doc(user.uid);
    await userRef.set({
      'displayName': displayName,
      'email': user.email,
      'profileImageUrl': user.photoURL ?? '',
      'bio': '',
      'username':
          '${displayName.replaceAll(' ', '').toLowerCase()}${_generateRandomString(4)}',
    });
  }
  // --- ここまで register_screen.dart のロジック ---

  Future<void> _navigateAfterSignIn(User user) async {
    pr('login_placeholder.dart: _navigateAfterSignIn called');
    if (!mounted) return;

    // main.dart のリスナーがトークン保存を行うため、
    // ここではナビゲーションに集中します。
    // (重複して呼んでも害は少ないですが、必須ではありません)
    // userData.setUser(user);
    // await saveTokenToDatabase();

    pr('Navigating back to AuthWrapper...');

    // navigatorKey を使って AuthWrapper に戻る
    if (navigatorKey.currentState != null) {
      pr('Using global navigatorKey to pushAndRemoveUntil AuthWrapper');
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          // AuthWrapperを再呼び出しして、認証状態の変更を検知させる
          builder: (context) => const AuthWrapper(),
        ),
        (route) => false,
      );
    } else {
      // Fallback: ローカルの Navigator を使用
      pr('Using local navigator to pushAndRemoveUntil AuthWrapper');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // デザイン改善: 背景にグラデーションを追加
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withOpacity(0.05),
              Colors.white,
              Colors.white,
              Colors.blue.withOpacity(0.05),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ブレークポイントを定義 (この値は調整可能)
            const double kWebBreakpoint = 800.0;

            if (constraints.maxWidth < kWebBreakpoint) {
              // モバイルレイアウト (Lottieが上)
              return _buildMobileLayout(context);
            } else {
              // Web/デスクトップレイアウト (横並び)
              return _buildWebLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // 小さな画面でもスクロール可能に
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- 1. 上部: Lottieアニメーション ---
            SizedBox(
              width: 300, // モバイル用にサイズ調整
              height: 300,
              child: Lottie.asset('assets/home.json'),
            ),
            const SizedBox(height: 24), // Lottieとカードの間のスペース

            // --- 2. 下部: ログインフォームのカード ---
            _buildLoginFormCard(), // 共通のフォームカードを呼び出す
          ],
        ),
      ),
    );
  }

  /// Web/デスクトップレイアウト（横並び）を構築
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // --- 1. 左側: Lottieアニメーション ---
          SizedBox(
            width: 450,
            height: 450,
            child: Lottie.asset('assets/home.json'),
          ),
          const SizedBox(width: 48), // Lottieとカードの間のスペース

          // --- 2. 右側: ログインフォームのカード ---
          _buildLoginFormCard(), // 共通のフォームカードを呼び出す
        ],
      ),
    );
  }

  Widget _buildLoginFormCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400), // カードの最大幅
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            // スライドアニメーションの定義
            transitionBuilder: (Widget child, Animation<double> animation) {
              // キーを使って、どちらのフォームかを判別
              final bool isSignIn = child.key == const ValueKey(true);

              // IN (入ってくる) アニメーション
              final slideIn = Tween<Offset>(
                begin: isSignIn
                    ? const Offset(-1.0, 0.0) // Sign Inは左から
                    : const Offset(1.0, 0.0), // Sign Upは右から
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeInOutCubic));

              // OUT (出ていく) アニメーション
              final slideOut = Tween<Offset>(
                begin: Offset.zero,
                end: isSignIn
                    ? const Offset(1.0, 0.0) // Sign Upは右へ
                    : const Offset(-1.0, 0.0), // Sign Inは左へ
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeInOutCubic));

              // `key` が `_showSignIn` と一致する = 新しいウィジェット（IN）
              if (child.key == ValueKey(_showSignIn)) {
                return SlideTransition(
                  position: slideIn,
                  child: child,
                );
              } else {
                return SlideTransition(
                  position: slideOut,
                  child: child,
                );
              }
            },
            // `_showSignIn` の値に応じて表示するフォームを切り替え
            child: _showSignIn
                ? _buildSignInForm(context) // Sign In フォーム
                : _buildSignUpForm(context), // Sign Up フォーム
          ),
        ),
      ),
    );
  }


  
  Widget _buildSignInForm(BuildContext context) {
    // アニメーションのためにキーを設定
    return Container(
      key: const ValueKey(true),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      child: Form(
        key: _signInFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                if (value == null ||
                    value.isEmpty ||
                    value.length < 6) {
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
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
              onPressed: _isSigningIn ? null : _signInWithEmailAndPassword,
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
            _isSigningIn
                ? const Center(child: CircularProgressIndicator())
                : SignInButton(
                    isSigningIn: _isSigningIn,
                    onPressed: _signInWithGoogleMobile,
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
                      // 画面遷移の代わりに State を変更
                      : () => setState(() => _showSignIn = false),
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
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    // アニメーションのためにキーを設定
    return Container(
      key: const ValueKey(false),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'fancy',
              ),
            ),
            const SizedBox(height: 48),

            // Display Name Text Field
            _buildTextField(
              controller: _registerDisplayNameController,
              hintText: 'Display Name',
              icon: Icons.person_outline,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please enter a display name'
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Email Text Field
            _buildTextField(
              controller: _registerEmailController,
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
              controller: _registerPasswordController,
              hintText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 48), // ボタンの上のスペース

            // Register Button
            ElevatedButton(
              onPressed: _isRegistering ? null : _registerWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: _isRegistering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: _isRegistering
                      ? null
                      // 画面遷移の代わりに State を変更
                      : () => setState(() => _showSignIn = true),
                  child: Text(
                    'Sign In',
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
    );
  }

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