import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/2_tenant_feature/3_profile/models/profile_model.dart';

class TenantListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10; // 1回に取得するドキュメント数

  List<UserProfile> _allTenants = [];
  List<UserProfile> _filteredTenants = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  String _searchQuery = '';

  List<UserProfile> get filteredTenants => _filteredTenants;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  TenantListViewModel() {
    fetchTenants(isInitial: true);
  }

  Future<void> fetchTenants({bool isInitial = false}) async {
    if (_isLoadingMore) return;

    if (isInitial) {
      _isLoading = true;
      _allTenants = [];
      _lastDocument = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      Query query = _firestore
          .collection('users_prof')
          .where('role', isEqualTo: 'tenant')
          .orderBy('displayName')
          .limit(_limit);

      if (!isInitial && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _allTenants.addAll(
            snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)));
      }
      _applyFilter();
    } catch (e) {
      print("Error fetching tenants: $e");
    } finally {
      if (isInitial) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  void applySearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTenants = _allTenants;
    } else {
      final query = _searchQuery.toLowerCase();
      // 検索時はローカルでフィルタリング（Firestoreへのクエリを減らすため）
      _filteredTenants = _allTenants.where((tenant) {
        final nameMatch = tenant.displayName.toLowerCase().contains(query);
        final occupationMatch = tenant.occupation.toLowerCase().contains(query);
        final locationMatch = tenant.location.toLowerCase().contains(query);
        return nameMatch || occupationMatch || locationMatch;
      }).toList();
    }
    notifyListeners();
  }
}