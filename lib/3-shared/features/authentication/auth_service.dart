import "package:flutter/material.dart";
import "sign_in_modal.dart";
import "sign_out_modal.dart";

enum PendingActionType {
  chatWithAgent, // チャット開始
  chatWithTenant,
  postComment,
}

// ★ アクションのデータを持つクラス
class PendingAction {
  final PendingActionType type;
  final Map<String, dynamic> payload; // 必要なデータ（postId, textなど）をここに詰める

  PendingAction({required this.type, required this.payload});
}

// ★ グローバル変数で保持（これ一つで全アクションに対応）
PendingAction? pendingAction;

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