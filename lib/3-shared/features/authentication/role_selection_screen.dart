import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/core/responsive/responsive_layout.dart';
import 'package:shared_data/shared_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../2_tenant_feature/3_profile/models/profile_model.dart';
import '../2_tenant_feature/3_profile/view/edit_profile_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String? displayName;
  const RoleSelectionScreen({super.key, this.displayName});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  Roles? _selectedRole;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Roleボタンが押された時の処理
  void _onRoleSelected(Roles role) {
    setState(() {
      _selectedRole = role;
    });

    // 2秒後に確定処理を実行（その間に "Change option" でキャンセル可能）
    _timer = Timer(const Duration(seconds: 2), () {
      _finalizeRoleSelection(role);
    });
  }

  /// "Change option" が押された時の処理（キャンセル）
  void _onChangeOption() {
    _timer?.cancel();
    setState(() {
      _selectedRole = null;
    });
  }

  /// 実際にFirestoreへ保存し画面遷移する処理
  Future<void> _finalizeRoleSelection(Roles role) async {
    pr('role_selection_screen.dart finalizing user role: $role');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final roleString = role == Roles.agent ? 'agent' : 'tenant';

      final userProfileData = {
        'role': roleString,
        'displayName': user.displayName ??
            (role == Roles.agent ? 'New Agent' : 'New User'),
        'profileImageUrl': user.photoURL ?? '',
        'bio': '',
        'username': user.displayName?.replaceAll(' ', '').toLowerCase() ??
            (role == Roles.agent ? 'newagent' : 'newuser'),
      };

      await FirebaseFirestore.instance
          .collection('users_prof')
          .doc(user.uid)
          .set(userProfileData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(rolePath, roleString);

      userData.setRole(role);

      if (!mounted) return;

      if (role == Roles.tenant) {
        // テナントの場合はプロフィール編集画面へ
        final newUserProfile = UserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'New User',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(
              userProfile: newUserProfile,
              isNewUser: true,
            ),
          ),
        );
      } else {
        // エージェントの場合はホームへ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // エラー時は選択状態を解除してリトライできるようにする
        _onChangeOption();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedRole == null
            ? _buildSelectionView() // 選択画面
            : _buildPreparingView(), // 準備中画面
      ),
    );
  }

  /// 準備中（ローディング）画面の構築
  Widget _buildPreparingView() {
    final roleString = _selectedRole == Roles.agent ? 'Agent' : 'Tenant';
    return Center(
      key: const ValueKey('preparing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Preparing your $roleString account...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _onChangeOption,
            child: const Text(
              'Change option',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 役割選択画面の構築（既存のUIをメソッド化）
  Widget _buildSelectionView() {
    return Center(
      key: const ValueKey('selection'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How will you be using our app?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            _buildRoleCard(
              context,
              iconDisplay: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.door_back_door_outlined,
                      size: 40, color: Colors.deepPurple),
                  SizedBox(width: 16),
                  Icon(Icons.bed, size: 40, color: Colors.deepPurple),
                ],
              ),
              label: "rent a room",
              onPressed: () => _onRoleSelected(Roles.tenant),
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              iconDisplay: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_business_sharp,
                      size: 40, color: Colors.deepPurple),
                  SizedBox(width: 16),
                  Icon(Icons.people, size: 40, color: Colors.deepPurple),
                ],
              ),
              label: "Agent/want roommate",
              onPressed: () => _onRoleSelected(Roles.agent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required Widget iconDisplay,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconDisplay,
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}