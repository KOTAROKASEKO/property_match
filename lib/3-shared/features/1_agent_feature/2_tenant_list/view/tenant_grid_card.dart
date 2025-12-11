// lib/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_grid_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';

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
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        // ★ Paddingを 16 -> 12 に縮小してスペースを確保
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Left Side: Avatar
              _buildAvatar(),

              const SizedBox(width: 12), // 間隔も少し詰める

              // 2. Right Side: Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Name & Age
                    _buildNameAndAge(),
                    
                    const SizedBox(height: 4), // 8 -> 4

                    // Tags: Gender, Occupation
                    _buildPrimaryTags(),

                    const SizedBox(height: 8), // 12 -> 8

                    // Details: Location, Budget, Move-in
                    _buildInfoRow(
                      Icons.location_on_outlined, 
                      tenant.location.isNotEmpty ? tenant.location : 'Any location'
                    ),
                    const SizedBox(height: 2), // 4 -> 2
                    _buildInfoRow(
                      Icons.attach_money, 
                      'RM ${tenant.budget.toStringAsFixed(0)} / mo'
                    ),
                    const SizedBox(height: 2), // 4 -> 2
                    _buildInfoRow(
                      Icons.calendar_today_outlined, 
                      tenant.moveinDate != null 
                        ? 'Move in: ${DateFormat('MMM d, yyyy').format(tenant.moveinDate!)}'
                        : 'Move in: Anytime'
                    ),

                    const SizedBox(height: 8), // 12 -> 8

                    // Hobbies
                    if (tenant.hobbies.isNotEmpty)
                      _buildHobbiesWrap(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28, // 32 -> 28 少し小さくしてバランス調整（任意）
          backgroundColor: Colors.grey[200],
          backgroundImage: tenant.profileImageUrl.isNotEmpty
              ? CachedNetworkImageProvider(tenant.profileImageUrl)
              : null,
          child: tenant.profileImageUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.grey, size: 28)
              : null,
        ),
        if (tenant.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameAndAge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            tenant.displayName,
            style: const TextStyle(
              color: Color(0xFFB45309),
              fontWeight: FontWeight.bold,
              fontSize: 16, // 18 -> 16
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${tenant.age} yrs',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13, // 14 -> 13
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryTags() {
    return Wrap(
      spacing: 6, // 8 -> 6
      runSpacing: 4,
      children: [
        if (tenant.gender.isNotEmpty && tenant.gender != 'Not specified')
          _buildTag(
            label: tenant.gender,
            backgroundColor: Colors.blue.shade50,
            textColor: Colors.blue.shade700,
          ),
        if (tenant.occupation.isNotEmpty && tenant.occupation != 'Not specified')
          _buildTag(
            label: tenant.occupation,
            icon: Icons.work_outline,
            backgroundColor: Colors.grey.shade100,
            textColor: Colors.grey.shade800,
          ),
      ],
    );
  }

  Widget _buildTag({
    required String label,
    IconData? icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // パディング縮小
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor), // 12 -> 10
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11, // 12 -> 11
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]), // 16 -> 14
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13, // 14 -> 13
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHobbiesWrap() {
    // 表示数を2つに制限して高さを抑える（必要に応じて3に戻してください）
    final displayHobbies = tenant.hobbies.take(2).toList();
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: displayHobbies.map((hobby) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hobby,
            style: TextStyle(
              fontSize: 10, // 11 -> 10
              color: Colors.grey[700],
              fontWeight: FontWeight.w500
            ),
          ),
        );
      }).toList(),
    );
  }
}