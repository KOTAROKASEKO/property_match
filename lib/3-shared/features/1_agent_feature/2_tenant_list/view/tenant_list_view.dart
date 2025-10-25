// lib/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/tenant_filter_options.dart';
import 'tenant_detail_screen.dart';
import 'tenant_filter_bottom_sheet.dart';
import 'tenant_grid_card.dart'; // ★ 新しいカードをインポート
import '../viewodel/tenant_list_viewmodel.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart'; // ★ TenantDetailSheetContentで必要

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TenantListViewModel>();

    // Infinite scroll ロジックはそのまま流用
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.fetchTenants();
      }
    });
  }

  @override
  void dispose() {
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

  // ★ カードタップ時に詳細をボトムシートで表示する関数
  void _showTenantDetails(UserProfile tenant) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8, // 80%で開く
            maxChildSize: 0.95, // 最大95%
            minChildSize: 0.5, // 最小50%
            expand: false,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                // ★ tenant_detail_screen.dart から持ってきた再利用ウィジェット
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: TenantDetailSheetContent(tenant: tenant),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TenantListViewModel>();

    return Scaffold(
      
      appBar: AppBar(
        toolbarHeight: 80.0,
        actions: [
          IconButton(
            
            onPressed:_showFilterSheet ,
            icon: Icon(Icons.filter_alt_outlined))
        ],
        title: const Row(children: [
          Icon(Icons.people_outline, color: Colors.white),
          SizedBox(width: 10),
          Text('Find Roommates', style: TextStyle(color: Colors.white)),
        ]),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      
      backgroundColor: Colors.grey[100],
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.fetchTenants(isInitial: true),
              // ★★★ ここからが変更点 ★★★
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1列に2人表示
                  crossAxisSpacing: 12, // 横のスペース
                  mainAxisSpacing: 12, // 縦のスペース
                  childAspectRatio: 0.75, // カードの縦横比 (縦長にする 1 / 1.33)
                ),
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
                  // ★ 新しいグリッドカードウィジェットを使用
                  return TenantGridCard(
                    tenant: tenant,
                    onTap: () => _showTenantDetails(tenant),
                  );
                },
              ),
              // ★★★ 変更点ここまで ★★★
            ),
    );
  }
}