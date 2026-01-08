import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得して、グリッド表示時などに対応できるようにする
    // (ここでは簡易的にLayoutBuilder等は使わず、Card内の相対サイズで指定します)
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 画像部分 (AspectRatio 16/10)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. タイトル
                  Container(
                    width: double.infinity,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 3. 家賃
                  Container(
                    width: 100.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 4. チップ (横並びの楕円)
                  Row(
                    children: [
                      _buildChip(),
                      const SizedBox(width: 8),
                      _buildChip(),
                      const SizedBox(width: 8),
                      _buildChip(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 5. 説明文 (2行分)
                  Container(
                    width: double.infinity,
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 200.0, // 2行目は少し短く
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Divider(height: 24),
                  // 6. ユーザー情報とアイコン
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // アイコンボタンのプレースホルダー
                      Container(width: 24, height: 24, color: Colors.white),
                      const SizedBox(width: 16),
                      Container(width: 24, height: 24, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip() {
    return Container(
      width: 60,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}