// lib/features/1_agent_feature/2_tenant_list/viewodel/tenant_list_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/2_tenant_list/repo/agent_search_service.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/post_service.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../model/tenant_filter_options.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';

class TenantListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 10; // Number of documents to fetch at a time

  List<UserProfile> _allTenants = [];
  List<UserProfile> _filteredTenants = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  DocumentSnapshot? _lastDocument;
  bool _hasMoreTenants = true;
  final PostService _postService = PostService(); // 座標変換用
  final AgentSearchService _agentSearchService = AgentSearchService();

  List<UserProfile> get filteredTenants => _filteredTenants;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<String> _blockedUserIds = [];
  TenantFilterOptions _filterOptions =
      TenantFilterOptions(minBudget: 0, maxBudget: 5000);
  TenantFilterOptions get filterOptions => _filterOptions;

  TenantListViewModel() {
    _fetchBlockedUsersAndThenTenants();
  }

  Future<void> _fetchBlockedUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users_prof')
          .doc(userData.userId)
          .collection('blockedList')
          .get();
      _blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching blocked users: $e");
    }
  }

  Future<void> _fetchBlockedUsersAndThenTenants() async {
    await _fetchBlockedUsers();
    fetchTenants(isInitial: true);
  }

  Future<void> fetchTenants({bool isInitial = false}) async {
    if (_isLoadingMore || (!isInitial && !_hasMoreTenants)) return;

    if (isInitial) {
      _isLoading = true;
      _lastDocument = null;
      _allTenants = [];
      _hasMoreTenants = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      Query query = _firestore
          .collection('users_prof')
          .where('role', isEqualTo: 'tenant');

      if (_filterOptions.minBudget != null && _filterOptions.minBudget! > 0) {
        query = query.where('budget',
            isGreaterThanOrEqualTo: _filterOptions.minBudget);
      }
      if (_filterOptions.maxBudget != null &&
          _filterOptions.maxBudget! < 5000) {
        query = query.where('budget',
            isLessThanOrEqualTo: _filterOptions.maxBudget);
      }
      if (_filterOptions.roomType != null) {
        query = query.where('roomType', isEqualTo: _filterOptions.roomType);
      }
      if (_filterOptions.pax != null) {
        query = query.where('pax', isEqualTo: _filterOptions.pax);
      }
      if (_filterOptions.nationality != null &&
          _filterOptions.nationality!.isNotEmpty) {
        query = query.where('nationality',
            isEqualTo: _filterOptions.nationality);
      }
      if (_filterOptions.gender != null) {
        query = query.where('gender', isEqualTo: _filterOptions.gender);
      }
      if (_filterOptions.hobbies != null && _filterOptions.hobbies!.isNotEmpty) {
        query = query.where('hobbies', arrayContainsAny: _filterOptions.hobbies);
      }
      // ★★★ Move-in Date Filter ★★★
      if (_filterOptions.moveinDate != null) {
        query = query.where('moveinDate',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(_filterOptions.moveinDate!));
      }

      // ★★★ Order by move-in date ★★★
      query = query.orderBy('moveinDate');

      if (_lastDocument != null && !isInitial) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreTenants = false;
      } else {
        _lastDocument = snapshot.docs.last;
        final newTenants = snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .where((tenant) => !_blockedUserIds.contains(
                tenant.uid)); // Filter blocked users locally
        _allTenants.addAll(newTenants);
      }

      _applyLocalSearchFilter(); // Apply search query locally
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


  Future<void> searchTenantsForProperty(PropertyTemplate template) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🚀 [TenantListViewModel] Searching for: ${template.name}');

      // 1. 物件の場所 (String) を 座標 (Lat/Lng) に変換
      Map<String, double>? coords;
      if (template.location.isNotEmpty) {
        // ★ ここでエラーが出ていたはず。_postServiceが初期化されていれば動きます
        coords = await _postService.getLatLng(template.location);
      }

      // 2. Algoliaで検索実行
      final results = await _agentSearchService.searchTenants(
        template: template,
        lat: coords?['lat'],
        lng: coords?['lng'],
      );

      // 3. 結果をリストに反映 (ブロックユーザー除外)
      _filteredTenants = results.where((tenant) => !_blockedUserIds.contains(tenant.uid)).toList();
      
      print('✅ [TenantListViewModel] Found ${_filteredTenants.length} tenants.');

    } catch (e) {
      print('❌ [TenantListViewModel] Error searching: $e');
      _filteredTenants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void applySearchQuery(String query) {
    _searchQuery = query;
    _applyLocalSearchFilter();
  }

  void applyFilters(TenantFilterOptions newFilters) {
    _filterOptions = newFilters;
    fetchTenants(isInitial: true); // Refetch from Firestore with new filters
  }

  // Local search is applied after fetching from Firestore.
  // For a more robust search, a dedicated search service like Algolia or Elasticsearch would be better.
  void _applyLocalSearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTenants = List.from(_allTenants);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredTenants = _allTenants.where((tenant) {
        final nameMatch = tenant.displayName.toLowerCase().contains(query);
        final occupationMatch =
            tenant.occupation.toLowerCase().contains(query);
        final locationMatch = tenant.location.toLowerCase().contains(query);
        return nameMatch || occupationMatch || locationMatch;
      }).toList();
    }
    notifyListeners();
  }
} 