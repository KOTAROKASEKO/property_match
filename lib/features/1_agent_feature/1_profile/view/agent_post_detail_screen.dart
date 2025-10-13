// lib/features/1_agent_feature/1_profile/view/agent_post_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/core/model/PostModel.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/view/agent_create_post_screen.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/view/post_details_card.dart';

class AgentPostDetailScreen extends StatelessWidget {
  final String postId;
  const AgentPostDetailScreen({super.key, required this.postId});

  Future<PostModel?> _fetchPost() async {
    final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    if (doc.exists) {
      return PostModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PostModel?>(
        future: _fetchPost(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Post not found or could not be loaded.'));
          }
          final post = snapshot.data!;
          return SingleChildScrollView(
            child: PostDetailsCard(
              post: post,
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreatePostScreen(post: post)),
                );
              },
              onDelete: () {
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}