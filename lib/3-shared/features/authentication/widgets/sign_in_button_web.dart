// lib/features/authentication/widgets/sign_in_button.dart (旧 sign_in_button_web.dart)
import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

class SignInButton extends StatelessWidget {
  final bool isSigningIn;
  // final VoidCallback? onPressed; // <-- 削除 (Webでは不要)

  const SignInButton({
    super.key,
    // required this.onPressed, // <-- 削除 (Webでは不要)
    required this.isSigningIn,
  });

  @override
  Widget build(BuildContext context) {
    // isSigningIn が true の場合は、login_placeholder 側で
    // CircularProgressIndicator が表示されるので、このロジックも不要
    // if (isSigningIn) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    // Web版では renderButton がクリックを処理する
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: gsi_web.renderButton(
          configuration: gsi_web.GSIButtonConfiguration()),
    );
  }
}