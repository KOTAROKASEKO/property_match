// lib/Common_model/post_actions_viewmodel.dart
import 'package:flutter/material.dart';

abstract class PostActionsViewModel extends ChangeNotifier {
  void toggleLike(String postId);
  Future<void> savePost(String postId);
} 