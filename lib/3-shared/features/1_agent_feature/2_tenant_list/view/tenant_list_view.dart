// lib/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/tenant_filter_options.dart';
import 'tenant_detail_screen.dart';
import 'tenant_filter_bottom_sheet.dart';
import 'tenant_grid_card.dart';
import '../viewodel/tenant_list_viewmodel.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';
// ★★★ フィルターパネルをインポート ★★★
import 'tenant_filter_panel.dart';

class TenantListView extends StatelessWidget {
  const TenantListView({super.key});

  @override
  Widget build(BuildContext context) {
    // ★ ChangeNotifierProvider を View の外に移動 (または親ウィジェットに配置)
    // この例ではそのままにしますが、通常は MyApp や上位のウィジェットで行うのが望ましい
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        viewModel.fetchTenants(); // isInitial: false (デフォルト)
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- ボトムシート表示ロジック (変更なし) ---
  void _showFilterSheet() async {
    final viewModel = context.read<TenantListViewModel>();
    final newFilters = await showModalBottomSheet<TenantFilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 背景を透明に
      builder: (_) => DraggableScrollableSheet( // DraggableSheetを追加
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) => Container( // 角丸のためにContainer追加
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: TenantFilterBottomSheet( // 既存のボトムシート用ウィジェット
                    initialFilters: viewModel.filterOptions,
                  ),
                ),
          ),
    );

    if (newFilters != null) {
      viewModel.applyFilters(newFilters);
    }
  }

  // --- テナント詳細表示ロジック (変更なし) ---
  void _showTenantDetails(UserProfile tenant) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
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
    // ViewModel をここで取得
    final viewModel = context.watch<TenantListViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ★★★ LayoutBuilder で画面幅を判定 ★★★
      body: LayoutBuilder(
        builder: (context, constraints) {
          // --- 画面幅の閾値 ---
          const double wideScreenThreshold = 800.0;
          final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;

          if (isWideScreen) {
            // --- ワイドスクリーン用レイアウト (Row) ---
            return Row(
              children: [
                // --- 左側: フィルターパネル (画面幅の約1/3) ---
                SizedBox(
                  width: constraints.maxWidth * 0.3, // 幅を指定
                  child: const TenantFilterPanel(), // 新しいフィルターパネル
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // --- 右側: テナントリスト (残り) ---
                Expanded(
                  child: _buildTenantGrid(viewModel), // グリッド表示用メソッド
                ),
              ],
            );
          } else {
            // --- ナロースクリーン用レイアウト (AppBar + Grid) ---
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 80.0,
                actions: [
                  IconButton(
                    onPressed: _showFilterSheet, // ボトムシートを表示
                    icon: const Icon(Icons.filter_alt_outlined),
                  )
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
              body: _buildTenantGrid(viewModel), // グリッド表示用メソッド
            );
          }
        },
      ),
    );
  }

  // --- ★★★ グリッド表示部分を別メソッドに抽出 ★★★ ---
  Widget _buildTenantGrid(TenantListViewModel viewModel) {
    // ローディング表示は GridView の前に配置
    if (viewModel.isLoading && viewModel.filteredTenants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
     if (!viewModel.isLoading && viewModel.filteredTenants.isEmpty) {
      return const Center(child: Text("No tenants found matching your criteria."));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchTenants(isInitial: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        // itemCount は isLoadingMore フラグを見て調整
        itemCount: viewModel.filteredTenants.length + (viewModel.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // --- もっと読み込むインジケータ ---
          if (index == viewModel.filteredTenants.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          // --- テナントカード ---
          final tenant = viewModel.filteredTenants[index];
          return TenantGridCard(
            tenant: tenant,
            onTap: () => _showTenantDetails(tenant),
          );
        },
      ),
    );
  }
}