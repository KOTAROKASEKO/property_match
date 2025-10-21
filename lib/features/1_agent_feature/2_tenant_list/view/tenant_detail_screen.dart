// lib/features/1_agent_feature/2_tenant_list/view/tenant_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/features/authentication/userdata.dart';

// --- 元の画面 ---
// これは、何らかの理由で詳細ページに直接遷移したい場合のために残しておく
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
      // ★ 再利用ウィジェットをそのまま使う
      body: TenantDetailSheetContent(tenant: tenant),
    );
  }
}


// --- ★★★ 新しい再利用可能なウィジェット ★★★ ---
// このウィジェットがボトムシートの「中身」になる
class TenantDetailSheetContent extends StatelessWidget {
  final UserProfile tenant;
  const TenantDetailSheetContent({super.key, required this.tenant});

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    // プレースホルダーのギャラリー画像リスト
    final List<String> photoUrls = [tenant.profileImageUrl]; 

    // ★ SingleChildScrollViewがボトムシート内でスクロールするために必要
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ギャラリー部分
          _buildPhotoGallery(context, photoUrls),
          
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
                    final chatThreadId =
                        _generateChatThreadId(userData.userId, tenant.uid);
                    
                    // ★ ボトムシートを閉じてからチャット画面に遷移する
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
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 以下は `tenant_detail_screen.dart` に元からあったヘルパーウィジェット ---

  Widget _buildPhotoGallery(BuildContext context, List<String> photoUrls) {
    if (photoUrls.isEmpty || photoUrls.every((url) => url.isEmpty)) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey)),
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
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
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
            width: 110,
            child: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          const SizedBox(width: 16),
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