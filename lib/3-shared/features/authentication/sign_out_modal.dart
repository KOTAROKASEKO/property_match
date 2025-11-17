// lib/3-shared/features/authentication/sign_out_modal.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart'; // ★ 1. Provider をインポート
import 'package:re_conver/app/localDB_Manager.dart';
import 'package:re_conver/main.dart';
import 'package:shared_data/shared_data.dart';
// ★ 2. ViewModel をインポート
import 'package:re_conver/3-shared/common_feature/chat/viewmodel/unread_messages_viewmodel.dart';

class SignOutModal extends StatefulWidget {
  const SignOutModal({super.key});

  @override
  State<SignOutModal> createState() => _SignOutModalState();
}

class _SignOutModalState extends State<SignOutModal> {
  @override
  Widget build(BuildContext context) {
    // ★ 3. ViewModel への参照を取得 (listen: false)
    final unreadViewModel = context.read<UnreadMessagesViewModel>();

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
                try {
                  pr('Initiating sign out process...');
                  var didSuccessfullyClearedSession = await deleteAllData();
                  pr('break point1');
                  
                  if(didSuccessfullyClearedSession){
                    await FirebaseAuth.instance.signOut();
                  }
                  
                  if (!kIsWeb) {
                    await GoogleSignIn.instance.disconnect();
                  }
                  
                  pr('break point3: FirebaseAuth.signOut() complete');
                  // 3. Clear local data and update UI
                  if (mounted) {
                    
                    // ★ 4. グローバルなStateをクリアする
                    userData.clearUser();
                    unreadViewModel.clear(); // ★★★ これを追加 ★★★

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign out successful.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // ★★★ FIX: Navigate to AuthWrapper, not LoginPlaceholderScreen ★★★
                    if (navigatorKey.currentState != null) {
                        navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const AuthWrapper(), 
                          ),
                          (route) => false,
                        );
                    } else {
                      // Fallback
                      Navigator.pop(context, true);
                    }
                  }else{
                    pr('sign_out_modal.dart : the widget is unmounted');
                  }
                } catch (error) {
                  pr('Error in logging out : $error');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign out failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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