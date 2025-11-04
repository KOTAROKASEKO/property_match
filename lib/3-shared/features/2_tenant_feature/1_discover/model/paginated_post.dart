
import '../../../../core/model/PostModel.dart';

class PaginatedPosts {
  final List<PostModel> posts;
  final bool hasMore; // ★ lastDocumentから変更

  PaginatedPosts({
    required this.posts,
    required this.hasMore, // ★ 変更
  });
}