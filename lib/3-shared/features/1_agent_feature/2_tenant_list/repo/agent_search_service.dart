import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';

class AgentSearchService {
  // 頂いたAPIキーを設定
  final SearchClient _client = SearchClient(
    appId: 'Z37M8J0YOF',
    apiKey: 'f53032958b1e5ade080d0ae5a5d14332',
  );

  /// 物件テンプレートと座標情報を使って、最適なテナントを検索する
  Future<List<UserProfile>> searchTenants({
    required PropertyTemplate template,
    required double? lat,
    required double? lng,
  }) async {
    const String indexName = 'tenant_index'; // Algoliaのインデックス名

    // 1. フィルタ条件の構築 (絶対条件)
    final List<String> filters = [
      'role:tenant', // テナントのみ
      'budget >= ${template.rent}', // 予算が家賃以上 (必要に応じて * 0.9 など調整)
    ];

    // 性別条件 (Mixの場合はフィルタしない)
    if (template.gender != 'Mix') {
      filters.add('gender:${template.gender}');
    }
    
    if (template.roomType.isNotEmpty) {
      filters.add('roomType:${template.roomType}');
    }

    pr('🔍 [Algolia Search] Query: "${template.location}", LatLng: $lat, $lng');
    pr('🔍 [Algolia Search] Filters: ${filters.join(' AND ')}');

    // 2. クエリの作成
    final query = SearchForHits(
      indexName: indexName,
      // ★ テキスト検索: "Preferred Areas" や "Location" (地名) にヒットさせる
      query: '',
      
      // ★ ジオ検索: 勤務地が物件から近い人をヒットさせる (半径15km)
      // 座標が取れている場合のみ適用
      aroundLatLng: (lat != null && lng != null) ? '$lat,$lng' : null,
      aroundRadius: 15000, // 15km
      
      // フィルタ適用
      filters: filters.join(' AND '),
      hitsPerPage: 20,
    );

    try {
      // 3. 実行
      final response = await _client.searchIndex(request: query);
      pr('✅ [Algolia Search] Hits: ${response.nbHits}');

      // 4. 結果をモデルに変換
      return response.hits.map((hit) {
        // Algoliaのレスポンス(Map)をFirestoreのドキュメント構造に合わせて整形
        final Map<String, dynamic> data = Map<String, dynamic>.from(hit);
        // objectIDをuidとして扱うため、必要ならセットする処理などは fromFirestore 側で吸収するか、ここで調整
        // 今回は UserProfile.fromFirestore が DocumentSnapshot を期待しているため、
        // 簡易的にモデルを直接生成します（推奨）
        
        return UserProfile(
          uid: hit.objectID,
          email: data['email'] as String? ?? '',
          displayName: data['displayName'] as String? ?? 'Unknown',
          profileImageUrl: data['profileImageUrl'] as String? ?? '',
          age: data['age'] as int? ?? 0,
          occupation: data['occupation'] as String? ?? '',
          location: data['location'] as String? ?? '',
          pets: data['pets'] as String? ?? '',
          pax: data['pax'] as int? ?? 1,
          budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
          roomType: data['roomType'] as String? ?? '',
          propertyType: data['propertyType'] as String? ?? '',
          nationality: data['nationality'] as String? ?? '',
          selfIntroduction: data['selfIntroduction'] as String? ?? '',
          gender: data['gender'] as String? ?? '',
          hobbies: (data['hobbies'] as List<dynamic>?)?.cast<String>() ?? [],
          // Algoliaからのデータには moveinDate が timestamp (秒) で入っている場合があるので注意
          // moveinDate: ... 
        );
      }).toList();
    } catch (e) {
      print('❌ [Algolia Search] Error: $e');
      return [];
    }
  }
}