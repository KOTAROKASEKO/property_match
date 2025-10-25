// lib/common_feature/chat/viewmodel/suggestion_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:shared_data/shared_data.dart';
import '../../../core/model/PostModel.dart';
import '../../../features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<dynamic> _suggestions = [];

  bool get isLoading => _isLoading;
  List<dynamic> get suggestions => _suggestions;

  SuggestionViewModel() {
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userData.role == Roles.tenant) {
        await _fetchPropertySuggestions();
      } else {
        await _fetchTenantSuggestions();
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchPropertySuggestions() async {
    final userProfileDoc = await _firestore.collection('users_prof').doc(userData.userId).get();
    if (!userProfileDoc.exists) return;

    final userProfile = UserProfile.fromFirestore(userProfileDoc);

    Query query = _firestore.collection('posts');

    if (userProfile.gender != 'Not specified' && userProfile.gender != 'Mix') {
      query = query.where('gender', whereIn: [userProfile.gender, 'Mix']);
    }
    if (userProfile.moveinDate != null) {
      query = query.where('durationStart', isLessThanOrEqualTo: userProfile.moveinDate);
    }
    if (userProfile.budget > 0) {
      query = query.where('rent', isLessThanOrEqualTo: userProfile.budget + 500).where('rent', isGreaterThanOrEqualTo: userProfile.budget - 500);
    }
    if (userProfile.location != 'Not specified') {
      // Simple text search for now. For better results, consider a search service like Algolia or text search features in Firestore extensions.
    }

    final snapshot = await query.limit(3).get();
    _suggestions = snapshot.docs.map((doc) => PostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
  }

  Future<void> _fetchTenantSuggestions() async {
    final userProfileDoc = await _firestore.collection('users_prof').doc(userData.userId).get();
    if (!userProfileDoc.exists) return;

    Query query = _firestore.collection('users_prof').where('role', isEqualTo: 'tenant');

    final snapshot = await query.limit(3).get();
    _suggestions = snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }
}