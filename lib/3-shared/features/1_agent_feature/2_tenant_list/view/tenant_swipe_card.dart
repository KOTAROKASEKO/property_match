// lib/features/1_agent_feature/2_tenant_list/view/tenant_swipe_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';

class TenantSwipeCard extends StatelessWidget {
  final UserProfile tenant;
  const TenantSwipeCard({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black45,
      clipBehavior: Clip.antiAlias, // Important for rounded corners on the image
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Layer: Image
          _buildProfileImage(),

          // 2. Middle Layer: Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0], // Gradient starts halfway down
              ),
            ),
          ),

          // 3. Top Layer: Info
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Age (Primary Identifier)
                Text(
                  '${tenant.displayName}, ${tenant.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 2, color: Colors.black54)
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Location (Critical Missing Info)
                if (tenant.location.isNotEmpty)
                  Text(
                    'Seeking: ${tenant.location}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(blurRadius: 2, color: Colors.black54)
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Key Metrics (The Non-Negotiables)
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    _buildInfoChip(Icons.account_balance_wallet_outlined,
                        'RM ${tenant.budget.toStringAsFixed(0)}'),
                    if (tenant.moveinDate != null)
                      _buildInfoChip(Icons.calendar_today_outlined,
                          DateFormat.yMMMd().format(tenant.moveinDate!)),
                    _buildInfoChip(Icons.bed_outlined, tenant.roomType),
                    _buildInfoChip(Icons.person_outline, tenant.gender),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return tenant.profileImageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: tenant.profileImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child:
                  const Center(child: Icon(Icons.person, color: Colors.grey)),
            ),
          )
        : Container(
            color: Colors.grey[200],
            child: const Center(
                child: Icon(Icons.person, size: 100, color: Colors.grey)),
          );
  }

  // Helper widget styled for a dark, overlay background
  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500)),
      backgroundColor: Colors.white.withOpacity(0.25),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}