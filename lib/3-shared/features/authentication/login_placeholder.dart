// lib/3-shared/features/authentication/login_placeholder.dart

import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Glassmorphism用
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:re_conver/3-shared/features/authentication/forgotpassword.dart';
import 'package:re_conver/main.dart';
import 'sign_in_button_stub.dart';
import 'package:shared_data/shared_data.dart';
import 'role_selection_screen.dart';
import '../../service/FirebaseApi.dart';

// 更新された部屋画像のリスト
const List<String> _roomImages = [
  'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1556911220-bff31c812dba?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1554995207-c18c203602cb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1493809842364-78817add7ffb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
];

class LoginPlaceholderScreen extends StatefulWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  State<LoginPlaceholderScreen> createState() => _LoginPlaceholderScreenState();
}

class _LoginPlaceholderScreenState extends State<LoginPlaceholderScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isSigningIn = false;
  bool _isRegistering = false;
  
  // ★ UI状態管理用の変数
  bool _showEmailForm = false; // メールフォームを表示するかどうか
  bool _isLoginMode = true;    // トグルボタンの状態 (Login vs New User)

  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _displayNameController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  // --- Google Sign-In Logic ---
  Future<void> _initializeGoogleSignIn() async {
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
            final GoogleSignInAuthentication googleAuth =
                await account.authentication;
            final String? idToken = googleAuth.idToken;

            if (idToken == null) throw 'Failed to get id token from Google.';

            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: null, // Webの場合はaccessToken不要
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
            if (mounted) setState(() => _isSigningIn = false);
          }
        }
      });
    } catch (error) {
      print("Error initializing Google Sign-In: $error");
    }
  }

  Future<void> _signInWithGoogleMobile() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      );
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      // ★ 修正: accessTokenの取得でエラーが出るため、ここでは null を渡します。
      // Firebase認証では通常 idToken があれば十分です。
      // もし特定のAPIで accessToken が必要な場合は、(googleAuth as dynamic).accessToken などで回避可能です。
      const String? accessToken = null; 

      if (idToken == null) throw 'Failed to get id token.';

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
      print("Error during Google Sign-In: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: $error')),
        );
      }
    }
  }

  // --- Email Logic (変更なし) ---
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
        if (mounted) setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    if (_registerFormKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmailController.text.trim(),
          password: _registerPasswordController.text.trim(),
        );
        if (userCredential.user != null) {
          String displayName = _displayNameController.text.trim();
          if (displayName.isEmpty) displayName = 'New user';

          await _createUserProfile(userCredential.user!, displayName);
          userData.setUser(userCredential.user);
          saveTokenToDatabase();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => RoleSelectionScreen(
                          displayName: displayName,
                        )),
                (route) => false);
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      } finally {
        if (mounted) setState(() => _isRegistering = false);
      }
    }
  }

  // 内部ヘルパー (変更なし)
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

  Future<void> _navigateAfterSignIn(User user) async {
    if (!mounted) return;
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色を黒っぽく設定（画像ロード前や隙間対策）
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. 背景のスクロール画像 (共通)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                        child: _AutoScrollColumn(
                            images: _roomImages,
                            duration: const Duration(seconds: 40),
                            offset: 0)),
                    Expanded(
                        child: _AutoScrollColumn(
                            images: _roomImages.reversed.toList(),
                            duration: const Duration(seconds: 50),
                            offset: 300)),
                    if (constraints.maxWidth > 600) // Web/タブレット用にもう1列
                      Expanded(
                          child: _AutoScrollColumn(
                              images: _roomImages,
                              duration: const Duration(seconds: 45),
                              offset: 100)),
                  ],
                ),
              ),
              // 2. オーバーレイ (暗くする)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              // 3. コンテンツ
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _showEmailForm
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildSelectionView(), // Google or Email 選択
                    secondChild: _buildEmailAuthCard(), // メールフォーム (Glassmorphism)
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ★ フェーズ1: 認証方法の選択画面
  Widget _buildSelectionView() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            "Welcome to\nBilikMatch",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -1.0,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black45,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Find your perfect room and tenant,\nNo more wait.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 48),

          // Google Sign In (メイン)
          if (_isSigningIn)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            SignInButton(
              isSigningIn: _isSigningIn,
              onPressed: () {
                setState(() => _isSigningIn = true);
                _signInWithGoogleMobile().whenComplete(() {
                  if (mounted) setState(() => _isSigningIn = false);
                });
              },
            ),
          
          const SizedBox(height: 16),
          
          // Divider
          Row(children: [
            Expanded(child: Divider(color: Colors.white24)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("OR", style: TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            Expanded(child: Divider(color: Colors.white24)),
          ]),
          
          const SizedBox(height: 16),

          // Email Sign In (サブ) - アウトラインボタンスタイル
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showEmailForm = true;
              });
            },
            icon: const Icon(Icons.email_outlined),
            label: const Text('Continue with Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ★ フェーズ2: メール認証フォーム (グラスモーフィズム + トグル)
  Widget _buildEmailAuthCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // ぼかし効果
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), // 半透明の黒背景
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                // 戻るボタンとタイトル
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _showEmailForm = false;
                          // キーボードを閉じる
                          FocusScope.of(context).unfocus();
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Email Authentication",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // バランス用のダミー
                  ],
                ),
                const SizedBox(height: 24),

                // ★ カスタムトグルボタン
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton("Log In", true),
                      _buildToggleButton("Sign Up", false),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // フォームの切り替え
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLoginMode
                      ? _buildSignInFormFields()
                      : _buildSignUpFormFields(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // トグルボタンのパーツ
  Widget _buildToggleButton(String text, bool isForLogin) {
    final isSelected = _isLoginMode == isForLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginMode = isForLogin),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5B1647).withOpacity(0.8) : Colors.transparent, // 選択時は少し紫っぽく
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ログインフォーム (中身のみ)
  Widget _buildSignInFormFields() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassTextField(
            controller: _emailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ForgotPassword()),
                );
              },
              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 24),
          _buildAuthButton(
            "Log In", 
            _isSigningIn ? null : _signInWithEmailAndPassword
          ),
        ],
      ),
    );
  }

  // 新規登録フォーム (中身のみ)
  Widget _buildSignUpFormFields() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassTextField(
            controller: _displayNameController,
            hintText: 'Display Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _registerEmailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _registerPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 32),
          _buildAuthButton(
            "Create Account", 
            _isRegistering ? null : _registerWithEmailAndPassword
          ),
        ],
      ),
    );
  }

  // グラスモーフィズム用テキストフィールド
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white), // 入力文字色
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // 半透明の背景
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
    );
  }

  // 共通アクションボタン
  Widget _buildAuthButton(String text, VoidCallback? onPressed) {
    final bool isLoading = (onPressed == null);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}

// 自動スクロールする画像カラム (既存のまま)
class _AutoScrollColumn extends StatefulWidget {
  final List<String> images;
  final Duration duration;
  final double offset;

  const _AutoScrollColumn({
    required this.images,
    required this.duration,
    this.offset = 0,
  });

  @override
  State<_AutoScrollColumn> createState() => _AutoScrollColumnState();
}

class _AutoScrollColumnState extends State<_AutoScrollColumn> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: widget.offset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double newOffset = _scrollController.offset + 1.0;
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final imageIndex = index % widget.images.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.images[imageIndex],
              fit: BoxFit.cover,
              height: 300,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(height: 300, color: Colors.grey[900]);
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(height: 300, color: Colors.grey[900]);
              },
            ),
          ),
        );
      },
    );
  }
}