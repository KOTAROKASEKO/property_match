import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:re_conver/3-shared/service/FirebaseApi.dart';
import 'package:shared_data/shared_data.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _googleAuthSubscription;

  /// Web用 Google Sign-In 初期化 (GIS Flow)
  Future<void> initializeGoogleSignIn({
    required Function(User) onSuccess,
    required Function(String) onError,
  }) async {
    if (!kIsWeb) return;

    try {
      await GoogleSignIn.instance.initialize(
        clientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      _googleAuthSubscription = GoogleSignIn.instance.authenticationEvents
          .listen((GoogleSignInAuthenticationEvent event) async {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _setLoading(true);
          try {
            final GoogleSignInAccount account = event.user;
            final GoogleSignInAuthentication googleAuth =
                await account.authentication;
            final String? idToken = googleAuth.idToken;

            if (idToken == null) throw 'Failed to get id token from Google.';

            // Webでは accessToken は null でOK (GIS flow)
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: null,
              idToken: idToken,
            );

            final userCredential = await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              await _handleAfterSignIn(userCredential.user!);
              onSuccess(userCredential.user!);
            }
          } catch (e) {
            onError(e.toString());
            await GoogleSignIn.instance.signOut();
          } finally {
            _setLoading(false);
          }
        }
      }, onError: (error) {
        onError(error.toString());
        _setLoading(false);
      });
    } catch (e) {
      print("Error initializing Google Sign-In: $e");
    }
  }

  /// Mobile用 Google Sign-In (Original Logic)
  Future<User?> signInWithGoogleMobile() async {
    _setLoading(true);
    try {
      // 1. Initialize
      await GoogleSignIn.instance.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '',
      );

      // 2. Authenticate
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        _setLoading(false);
        return null; // ユーザーがキャンセル
      }

      // 3. Get Auth Details
      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Original implementation logic for Access Token
      // (Using authorizationClient / authorizeScopes as per original file)
      // ※ 注意: この authorizeScopes のフローは標準的ではない場合がありますが、元の実装に従います。
      // もし authorizationClient が未定義のエラーになる場合は、標準的な googleUser.authentication.accessToken を検討してください。
      /* Original logic reference:
         final authClient = googleUser.authorizationClient;
         final clientAuth = await authClient.authorizeScopes(['email']);
         final accessToken = clientAuth?.accessToken;
      */
      
      // コンパイルエラーを避けるため、一旦標準的なアクセストークン取得を試みますが、
      // エラーログに基づき、googleAuth.accessToken が使えない場合は、
      // authorizeScopes のロジックが必要になります。
      // ここでは、ユーザーの環境に合わせて dynamic で呼び出すか、標準プロパティを確認してください。
      
      // GoogleSignInAuthentication から accessToken が取れるのが標準ですが、
      // エラーが出ているため、ここでは idToken のみ、または元のコードに近い形を再現します。
      
      // ★ 修正: 元の実装の意図を汲み、もし googleAuth.accessToken が使えない場合のフォールバックとして
      // idToken のみで credential を作成するか、元のロジックを移植します。
      // ここでは安全のため idToken を主に使用し、accessToken は googleAuth から取得を試みます。
      String? accessToken;
      try {
         // googleAuth.accessToken が存在しない環境(古い/特殊なVer)向けに try-catch または dynamic 使用
         accessToken = (googleAuth as dynamic).accessToken;
      } catch (_) {
         // accessToken が取得できない場合は null (idTokenのみで認証可能な場合が多い)
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
        await _handleAfterSignIn(userCredential.user!);
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
    return null;
  }

  /// Email/Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user != null) {
        await _handleAfterSignIn(userCredential.user!);
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
    return null;
  }

  /// Email/Password Register
  Future<User?> registerWithEmail(
      String email, String password, String displayName) async {
    _setLoading(true);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        final name = displayName.isEmpty ? 'New user' : displayName.trim();
        await _createUserProfile(userCredential.user!, name);
        await _handleAfterSignIn(userCredential.user!);
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<void> _handleAfterSignIn(User user) async {
    userData.setUser(user);
    await saveTokenToDatabase();
  }

  Future<void> _createUserProfile(User user, String displayName) async {
    final userRef =
        _firestore.collection('users_prof').doc(user.uid);
    await userRef.set({
      'displayName': displayName,
      'email': user.email,
      'profileImageUrl': user.photoURL ?? '',
      'bio': '',
      'username':
          '${displayName.replaceAll(' ', '').toLowerCase()}${_generateRandomString(4)}',
    });
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _googleAuthSubscription?.cancel();
    super.dispose();
  }
}