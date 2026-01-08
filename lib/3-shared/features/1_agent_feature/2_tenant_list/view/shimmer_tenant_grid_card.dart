import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTenantGridCard extends StatelessWidget {
  const ShimmerTenantGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景（画像部分）
            Container(color: Colors.white),
            
            // テキスト部分のプレースホルダー
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前用
                  Container(
                    height: 16, 
                    width: 120, 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 予算用
                  Container(
                    height: 14, 
                    width: 80, 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 部屋タイプ用
                  Container(
                    height: 12, 
                    width: 60, 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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
}