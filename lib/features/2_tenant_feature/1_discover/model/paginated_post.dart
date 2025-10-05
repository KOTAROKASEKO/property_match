import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/core/model/PostModel.dart';

class PaginatedPosts {
  final List<PostModel> posts;
  final DocumentSnapshot? lastDocument;

  PaginatedPosts({
    required this.posts,
    this.lastDocument,
  });
}