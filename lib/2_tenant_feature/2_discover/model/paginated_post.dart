import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';

class PaginatedPosts {
  final List<Post> posts;
  final DocumentSnapshot? lastDocument;

  PaginatedPosts({
    required this.posts,
    this.lastDocument,
  });
}