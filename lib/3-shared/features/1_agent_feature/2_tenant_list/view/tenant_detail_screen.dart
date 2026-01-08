// lib/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // ★ 追加: シェア機能用
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';

// --- 詳細画面として直接開く場合に使用 ---
class TenantDetailScreen extends StatelessWidget {
  final UserProfile tenant;
  const TenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.displayName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TenantDetailSheetContent(tenant: tenant),
        ),
      ),
    );
  }
}

// --- ★★★ 再利用可能な詳細コンテンツウィジェット ★★★ ---
// ボトムシートやダイアログ、詳細画面の中身として使用します
class TenantDetailSheetContent extends StatelessWidget {
  final UserProfile tenant;
  const TenantDetailSheetContent({super.key, required this.tenant});

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // ★★★ 追加: シェア機能の実装 ★★★
  void _shareTenantProfile() {
    // サーバーサイドで設定したURLスキームに合わせる (/tenant/UID)
    final String shareUrl = 'https://bilikmatch.com/tenant/${tenant.uid}';
    
    final String textToShare = 'Check out this tenant on BilikMatch:\n\n'
        '👤 *Name:* ${tenant.displayName}\n'
        '💼 *Occupation:* ${tenant.occupation}\n'
        '📍 *Seeking:* ${tenant.location}\n'
        '💰 *Budget:* RM ${tenant.budget.toStringAsFixed(0)}\n\n'
        '$shareUrl\n\n'
        'View full profile in the app!';
    
    Share.share(textToShare, subject: 'Tenant Profile: ${tenant.displayName}');
  }

  @override
  Widget build(BuildContext context) {
    // 現在はプロフィール画像1枚のみをリストとして扱う
    final List<String> photoUrls = [tenant.profileImageUrl]; 

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ギャラリー部分 (Stackにしてシェアボタンを重ねる)
          Stack(
            children: [
              _buildPhotoGallery(context, photoUrls),
              
              // ★★★ 追加: 右上のシェアボタン ★★★
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.deepPurple),
                    onPressed: _shareTenantProfile,
                    tooltip: 'Share Profile',
                  ),
                ),
              ),
            ],
          ),
          
          // 詳細情報部分
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.person_pin_outlined, "Profile"),
                _buildDetailRow('About', tenant.selfIntroduction),
                _buildDetailRow('Age', '${tenant.age}'),
                _buildDetailRow('Gender', tenant.gender),
                _buildDetailRow('Nationality', tenant.nationality),
                if (tenant.hobbies.isNotEmpty)
                  _buildDetailRow('Hobbies', tenant.hobbies.join(', ')),

                const SizedBox(height: 24),
                _buildSectionHeader(Icons.home_work_outlined, "Preferences"),
                _buildDetailRow('Preferred Location', tenant.location),
                _buildDetailRow('Budget', 'RM ${tenant.budget.toStringAsFixed(0)}'),
                _buildDetailRow('Room Type', tenant.roomType),
                _buildDetailRow('Property Type', tenant.propertyType),
                _buildDetailRow('Pets Allowed', tenant.pets),
                
                const SizedBox(height: 32),
                
                // チャット開始ボタン
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      pendingAction = PendingAction(
                        type: PendingActionType.chatWithTenant,
                        payload: {'tenant': tenant}, // ログイン後にこのテナントとチャット再開
                      );
                      showSignInModal(context);
                    } else {
                      final chatThreadId = _generateChatThreadId(userData.userId, tenant.uid);
                      
                      // ボトムシートが開いていれば閉じる
                      if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                      }
                      
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IndividualChatScreenWithProvider(
                            otherUserUid: tenant.uid,
                            otherUserName: tenant.displayName,
                            otherUserPhotoUrl: tenant.profileImageUrl,
                            chatThreadId: chatThreadId,
                          ),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ヘルパーウィジェット ---

  Widget _buildPhotoGallery(BuildContext context, List<String> photoUrls) {
    // 画像がない場合のプレースホルダー
    if (photoUrls.isEmpty || photoUrls.every((url) => url.isEmpty)) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 60, color: Colors.grey),
              SizedBox(height: 8),
              Text("No Image Available", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: photoUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: photoUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    if (value.isEmpty || value == 'Not specified') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // ラベル幅を少し調整
            child: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}