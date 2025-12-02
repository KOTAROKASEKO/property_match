// lib/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:template_hive/template_hive.dart'; // Needed for PropertyTemplate
import '../model/tenant_filter_options.dart';
import 'tenant_detail_screen.dart';
import 'tenant_filter_bottom_sheet.dart';
import 'tenant_grid_card.dart';
import '../viewodel/tenant_list_viewmodel.dart';
import '../../../2_tenant_feature/3_profile/models/profile_model.dart';
import 'tenant_filter_panel.dart';

class TenantListView extends StatelessWidget {
  const TenantListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TenantListViewBody();
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
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet( 
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) => Container( 
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: TenantFilterBottomSheet( 
                    initialFilters: viewModel.filterOptions,
                  ),
                ),
          ),
    );

    if (newFilters != null) {
      viewModel.applyFilters(newFilters);
    }
  }

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
    final viewModel = context.watch<TenantListViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double wideScreenThreshold = 800.0;
          final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;

          if (isWideScreen) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.3,
                  child: const TenantFilterPanel(), 
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Column( 
                    children: [
                      _buildSmartSearchBar(context),
                      // ★ ADDED: Selected Property Card
                      if (viewModel.selectedTemplate != null)
                        _buildSelectedPropertyCard(context, viewModel.selectedTemplate!, viewModel),
                        
                      Expanded(
                        child: _buildTenantGrid(viewModel, isWideScreen: true),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 80.0,
                actions: [
                  IconButton(
                    onPressed: _showFilterSheet,
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
              body: Column( 
                children: [
                  _buildSmartSearchBar(context),
                  // ★ ADDED: Selected Property Card
                  if (viewModel.selectedTemplate != null)
                    _buildSelectedPropertyCard(context, viewModel.selectedTemplate!, viewModel),
                    
                  Expanded(
                    child: _buildTenantGrid(viewModel, isWideScreen: false),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // ★ NEW: Futuristic Property Card
  Widget _buildSelectedPropertyCard(BuildContext context, PropertyTemplate template, TenantListViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E004F), Color(0xFF1A1A1A)], // Deep Purple to Dark Grey
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative background glow
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('noise.png'), // Optional texture
                    fit: BoxFit.cover,
                    opacity: 0.1
                  )
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Futuristic Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 26),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "ACTIVE MATCHING",
                              style: TextStyle(
                                color: Colors.purpleAccent[100],
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)]
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${template.location} • RM${template.rent}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Close/Clear Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        viewModel.clearSelectedProperty();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Matching cleared. Showing all tenants.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(Icons.close, color: Colors.white70, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantGrid(TenantListViewModel viewModel, {required bool isWideScreen}) {
    if (viewModel.isLoading && viewModel.filteredTenants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
     if (!viewModel.isLoading && viewModel.filteredTenants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No tenants found.", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            if (viewModel.selectedTemplate != null)
              TextButton(
                onPressed: () => viewModel.clearSelectedProperty(),
                child: const Text("Clear Property Filter"),
              )
          ],
        ),
      );
    }

    final SliverGridDelegate delegate = isWideScreen
        ? const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          )
        : const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          );

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchTenants(isInitial: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        gridDelegate: delegate,
        itemCount: viewModel.filteredTenants.length + (viewModel.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.filteredTenants.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final tenant = viewModel.filteredTenants[index];
          return TenantGridCard(
            tenant: tenant,
            onTap: () => _showTenantDetails(tenant),
          );
        },
      ),
    );
  }

  Widget _buildSmartSearchBar(BuildContext context) {
    // Same as previous implementation
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // Increased bottom padding slightly
      child: Material(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () =>  _showPropertySelectorSheet(context),
            
            
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, size: 20, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Find with your property",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "Tap here!!",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPropertySelectorSheet(BuildContext context) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ★重要: これをtrueにするとコンテンツの高さに応じてシートが伸縮します
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 1. ログイン済みの場合: リストを表示するため DraggableScrollableSheet を使用
        if (isLoggedIn) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (_, scrollController) {
              return _buildLoggedInSheetContent(context);
            },
          );
        } 
        // 2. 未ログインの場合: コンテンツの高さに合わせて自動調整 (DraggableScrollableSheetを使わない)
        else {
          return SingleChildScrollView(
            // キーボードが出ても隠れないようにpaddingを調整
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildGuestUpsellContent(context),
          );
        }
      },
    );
  }

  // --- ログイン済みユーザー用のコンテンツ (リスト表示) ---
  Widget _buildLoggedInSheetContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Select a Property",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PropertyTemplateCarouselWidget(
              onTemplateSelected: (template) {
                Navigator.pop(context);
                context
                    .read<TenantListViewModel>()
                    .searchTenantsForProperty(template);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Searching tenants for ${template.name}...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 未ログインユーザー用のコンテンツ (高さ自動調整 & オーバーフロー防止) ---
  Widget _buildGuestUpsellContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // ★重要: コンテンツの高さに合わせて縮む設定
          children: [
            // ドラッグハンドル
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // アイコン
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // タイトル
            const Text(
              "Search with your Property!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              "Don't search manually. Select one of your properties, and we'll instantly show you tenants whose budget and location preferences match yours.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ベネフィットリスト
            _buildBenefitRow(Icons.check_circle, "Match by Budget & Location"),
            const SizedBox(height: 8),
            _buildBenefitRow(Icons.check_circle, "Save hours of scrolling"),
            
            const SizedBox(height: 32),

            // アクションボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showSignInModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log in to Match Properties",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ヘルパーウィジェット
  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  
}