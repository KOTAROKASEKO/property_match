import "package:flutter/material.dart";
import "package:re_conver/authentication/sign_in_modal.dart";
import "package:re_conver/authentication/sign_out_modal.dart";

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