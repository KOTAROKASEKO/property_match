import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/chat_template/view/property_template_carousel_widget.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:re_conver/l10n/app_localizations.dart';
import 'package:template_hive/template_hive.dart';
import '../model/tenant_filter_options.dart';
import 'tenant_detail_screen.dart';
import 'tenant_filter_bottom_sheet.dart';
import 'tenant_grid_card.dart';
// ★ 追加: Shimmerカードをインポート
import 'shimmer_tenant_grid_card.dart'; 
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
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double wideScreenThreshold = 800.0;
          final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;

          Widget content;
          
          if (!viewModel.hasSearched) {
            content = _buildSearchPrompt(context, viewModel, l);
          } else {
            content = _buildTenantGrid(viewModel, isWideScreen: isWideScreen);
          }

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
                      _buildSmartSearchBar(context, l),
                      if (viewModel.selectedTemplate != null)
                        _buildSelectedPropertyCard(context, viewModel.selectedTemplate!, viewModel, l),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Row(children: [
                  const Icon(Icons.search, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(l.tenantList_title, style: const TextStyle(color: Colors.white)),
                ]),
                backgroundColor: Colors.deepPurple,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              body: Column( 
                children: [
                  _buildSmartSearchBar(context, l),
                  if (viewModel.selectedTemplate != null)
                    _buildSelectedPropertyCard(context, viewModel.selectedTemplate!, viewModel, l),
                  Expanded(child: content),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchPrompt(BuildContext context, TenantListViewModel viewModel, AppLocalizations l) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 64,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.tenantList_searchPromptTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.tenantList_searchPromptDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => _showPropertySelectorSheet(context),
              icon: const Icon(Icons.auto_awesome),
              label: Text(l.tenantList_matchButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPropertyCard(BuildContext context, PropertyTemplate template, TenantListViewModel viewModel, AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E004F), Color(0xFF1A1A1A)],
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
                    image: AssetImage('noise.png'), 
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
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l.tenantList_activeMatching,
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
                  
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        viewModel.clearSelectedProperty();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.tenantList_clearSnackBar),
                            duration: const Duration(seconds: 1),
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
    final SliverGridDelegate delegate = isWideScreen
        ? const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2, 
          )
        : const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6, 
          );

    // ★★★ 修正: ローディング中はShimmerを表示 ★★★
    if (viewModel.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: delegate,
        itemCount: 6, // 6枚のローディングカードを表示
        itemBuilder: (context, index) {
          return const ShimmerTenantGridCard(); // Shimmerカードを表示
        },
      );
    }

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

  Widget _buildSmartSearchBar(BuildContext context, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), 
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.tenantList_searchBarTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        l.tenantList_searchBarSubtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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
    final l = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (isLoggedIn) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (_, scrollController) {
              return _buildLoggedInSheetContent(context, l);
            },
          );
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildGuestUpsellContent(context, l)
          );
        }
      },
    );
  }

  Widget _buildLoggedInSheetContent(BuildContext context, AppLocalizations l) {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              l.tenantList_sheetTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    content: Text(l.tenantList_searchingSnackBar(template.name)),
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

  Widget _buildGuestUpsellContent(BuildContext context, AppLocalizations l) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
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

            Text(
              l.tenantList_guestSheetTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              l.tenantList_guestSheetDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildBenefitRow(Icons.check_circle, l.tenantList_benefitMatch),
            const SizedBox(height: 8),
            _buildBenefitRow(Icons.check_circle, l.tenantList_benefitSaveTime),
            
            const SizedBox(height: 32),

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
                child: Text(
                  l.tenantList_loginButton,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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