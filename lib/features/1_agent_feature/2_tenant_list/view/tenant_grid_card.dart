// lib/features/1_agent_feature/2_tenant_list/view/tenant_grid_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/features/2_tenant_feature/3_profile/models/profile_model.dart';

class TenantGridCard extends StatelessWidget {
  final UserProfile tenant;
  final VoidCallback onTap;

  const TenantGridCard({
    super.key,
    required this.tenant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // 画像をカードの角に合わせる
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. ベース: 画像
            _buildProfileImage(tenant.profileImageUrl),

            // 2. グラデーション (テキストの可読性のため)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0], // 下から60%を暗くする
                ),
              ),
            ),

            // 3. 情報
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前
                  Text(
                    tenant.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 予算 (最重要情報の一つ)
                  Text(
                    'RM ${tenant.budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 部屋タイプ
                  Text(
                    tenant.roomType,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.person, color: Colors.grey, size: 40),
            ),
          )
        : Container(
            color: Colors.grey[200],
            child: const Center(
                child: Icon(Icons.person, size: 40, color: Colors.grey)),
          );
  }
}