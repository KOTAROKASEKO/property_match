
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:re_conver/app/localDB_Manager.dart';
import 'package:shared_data/shared_data.dart';

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
                    userData.clearUser();
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
