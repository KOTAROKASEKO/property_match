import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TenantListViewModel>();

    _searchController.addListener(() {
      viewModel.applySearchQuery(_searchController.text);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.fetchTenants();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TenantListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Tenants'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, occupation, location...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => viewModel.fetchTenants(isInitial: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: viewModel.filteredTenants.length +
                          (viewModel.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == viewModel.filteredTenants.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
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
              ? NetworkImage(tenant.profileImageUrl)
              : null,
          child: tenant.profileImageUrl.isEmpty
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        title: Text(tenant.displayName,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle:
            Text('${tenant.location}', style: const TextStyle(fontSize: 14)),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Move-in Date',
                    tenant.moveinDate == null
                        ? 'Not specified'
                        : DateFormat.yMMMd().format(tenant.moveinDate!),
                ),
                _buildDetailRow(
                    Icons.person_outline, 'About', tenant.selfIntroduction),
                _buildDetailRow(
                    Icons.flag_outlined, 'Nationality', tenant.nationality),
                _buildDetailRow(Icons.cake_outlined, 'Age', '${tenant.age}'),
                _buildDetailRow(Icons.location_on_outlined,
                    'Work/Study Location', tenant.location),
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple.shade300, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}