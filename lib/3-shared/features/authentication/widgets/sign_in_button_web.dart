// lib/features/authentication/widgets/sign_in_button.dart (旧 sign_in_button_web.dart)
import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

class SignInButton extends StatelessWidget {
  final bool isSigningIn;
  final VoidCallback? onPressed;

  const SignInButton({
    super.key,
    required this.onPressed,
    required this.isSigningIn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: gsi_web.renderButton(
          configuration: gsi_web.GSIButtonConfiguration()),
    );
  }
}