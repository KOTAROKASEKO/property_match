import "package:flutter/material.dart";
import "package:re_conver/authentication/auth_screen.dart";

Future<bool?> showSignInModal(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext bc) {
      return const SignInModal();
    },
  );
}

Future<bool?> showSignOutModal(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext bc) {
      return const SignOutModal();
    },
  );
}