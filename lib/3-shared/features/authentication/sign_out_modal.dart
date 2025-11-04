import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
                    userData.clearUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign out successful.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                } catch (error) {
                  pr('Error in logging out : $error');
                  // Optionally, show the error to the user
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
