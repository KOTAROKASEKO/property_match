// lib/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/model/tenant_filter_options.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/view/tenant_filter_bottom_sheet.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/viewodel/tenant_list_viewmodel.dart';
import 'package:re_conver/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/features/authentication/userdata.dart';

class TenantListView extends StatelessWidget {
  const TenantListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TenantListViewModel(),
      child: const _TenantListViewBody(),
    );
  }
}

class _TenantListViewBody extends StatefulWidget {
  const _TenantListViewBody();

  @override
  State<_TenantListViewBody> createState() => _TenantListViewBodyState();
}

class _TenantListViewBodyState extends State<_TenantListViewBody> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  

  bool _isSearchUIVisible = true; // ★ UIの表示状態を管理するフラグ

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TenantListViewModel>();

    _searchController.addListener(() {
      viewModel.applySearchQuery(_searchController.text);
    });

    _scrollController.addListener(() {
      // スクロール位置の監視
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.fetchTenants();
      }

      // ★ スクロール方向を監視してUIの表示/非表示を切り替え
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isSearchUIVisible) {
        setState(() {
          _isSearchUIVisible = false;
        });
      } else if (direction == ScrollDirection.forward && !_isSearchUIVisible) {
        setState(() {
          _isSearchUIVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() async {
    final viewModel = context.read<TenantListViewModel>();
    final newFilters = await showModalBottomSheet<TenantFilterOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          TenantFilterBottomSheet(initialFilters: viewModel.filterOptions),
    );

    if (newFilters != null) {
      viewModel.applyFilters(newFilters);
    }
  }
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TenantListViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        backgroundColor: viewModel.filterOptions.isClear
            ? const Color.fromARGB(255, 168, 168, 168)
            : Colors.deepPurple[100],
        child: const Icon(Icons.filter_list, color: Colors.black54),
      ),
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.people,color: Colors.white,),
          SizedBox(width: 10,),
          Text('Find Tenants', style:TextStyle(color:Colors.white)),
          ]),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        viewModel.fetchTenants(isInitial: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: viewModel.filteredTenants.length +
                          (viewModel.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == viewModel.filteredTenants.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child:Center(child: CircularProgressIndicator()),
                          );
                        }
                        final tenant = viewModel.filteredTenants[index];
                        return TenantCard(tenant: tenant);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class TenantCard extends StatelessWidget {
  final UserProfile tenant;
  const TenantCard({super.key, required this.tenant});

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shadowColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: tenant.profileImageUrl.isNotEmpty
              ? CachedNetworkImageProvider(tenant.profileImageUrl)
              : null,
          child: tenant.profileImageUrl.isEmpty
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        title: Text(tenant.displayName,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildDetailRow(Icons.location_on_outlined, 'Location', tenant.location, isCompact: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildInfoChip(Icons.person_outline, tenant.gender),
                _buildInfoChip(Icons.flag_outlined, tenant.nationality),
                if (tenant.moveinDate != null)
                  _buildInfoChip(Icons.calendar_today_outlined, DateFormat.yMMMd().format(tenant.moveinDate!)),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                _buildDetailRow(
                    Icons.person_outline, 'About', tenant.selfIntroduction),
                _buildDetailRow(Icons.cake_outlined, 'Age', '${tenant.age}'),
                _buildDetailRow(Icons.group_outlined, 'Pax', '${tenant.pax}'),
                _buildDetailRow(Icons.pets_outlined, 'Pets', tenant.pets),
                _buildDetailRow(Icons.account_balance_wallet_outlined,
                    'Budget', 'RM ${tenant.budget.toStringAsFixed(0)}'),
                _buildDetailRow(Icons.apartment_outlined, 'Property Type',
                    tenant.propertyType),
                _buildDetailRow(
                    Icons.bed_outlined, 'Room Type', tenant.roomType),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final chatThreadId =
                        _generateChatThreadId(userData.userId, tenant.uid);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => IndividualChatScreenWithProvider(
                          otherUserUid: tenant.uid,
                          otherUserName: tenant.displayName,
                          otherUserPhotoUrl: tenant.profileImageUrl,
                          chatThreadId: chatThreadId,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 14, color: Colors.deepPurple),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple.shade300, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!isCompact)
                Text(title, style: const TextStyle(color: Colors.grey)),
                if(!isCompact)
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(
                      fontWeight: isCompact ? FontWeight.normal : FontWeight.w500, fontSize: isCompact ? 14 : 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}