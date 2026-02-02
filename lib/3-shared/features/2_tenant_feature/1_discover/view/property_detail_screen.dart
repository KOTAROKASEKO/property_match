// lib/3-shared/features/2_tenant_feature/1_discover/view/property_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/services/tenant_api_service.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/comment_bottomsheet.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/post_card.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/deeplink_viewmodel.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:re_conver/l10n/app_localizations.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import '../../../../common_feature/post_actions_viewmodel.dart';
import '../../../../core/model/PostModel.dart';
import 'agent_profile_screen.dart';
import 'full_pic_screen.dart';

/// Full-page property detail with AI assessment from bilikmatch-tenant API.
class PropertyDetailScreen extends StatefulWidget {
  final String postId;
  final PostModel? post;

  const PropertyDetailScreen({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late DeepLinkViewModel _viewModel;
  bool _isLoading = true;
  String? _error;

  PropertyAssessment? _assessment;
  bool _assessmentLoading = false;
  String? _assessmentError;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = DeepLinkViewModel();
    if (widget.post != null) {
      _viewModel.setPost(widget.post!);
      _isLoading = false;
      _recordDetailView(widget.post!.id);
    } else {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();
      if (doc.exists) {
        bool isSaved = false;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final savedDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('savedPosts')
              .doc(widget.postId)
              .get();
          isSaved = savedDoc.exists;
          userData.setUser(user);
        }
        final post = PostModel.fromFirestore(doc, isSaved: isSaved);
        _viewModel.setPost(post);
        _recordDetailView(post.id);
      } else {
        setState(() => _error = "This listing is no longer available.");
      }
    } catch (e) {
      setState(() => _error = "Failed to load listing: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordDetailView(String postId) async {
    try {
      await TenantApiService.recordDetailView(postId);
    } catch (_) {}
  }

  Future<void> _fetchAssessment(PostModel post) async {
    if (_assessmentLoading || _assessment != null) return;
    setState(() {
      _assessmentLoading = true;
      _assessmentError = null;
    });
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final assessment = await TenantApiService.fetchAssess(
        propertyId: post.id,
        propertyLocation: post.location.isNotEmpty ? post.location : null,
        lang: locale,
      );
      if (mounted) {
        setState(() {
          _assessment = assessment;
          _assessmentLoading = false;
        });
      }
    } on TenantApiException catch (e) {
      if (mounted) {
        setState(() {
          _assessmentError = e.message;
          _assessmentLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _assessmentError = e.toString();
          _assessmentLoading = false;
        });
      }
    }
  }

  void _startChat(PostModel post) {
    if (FirebaseAuth.instance.currentUser == null) {
      showSignInModal(context);
      return;
    }
    final chatThreadId = _generateChatThreadId(userData.userId, post.userId);
    final propertyTemplate = PropertyTemplate(
      postId: post.id,
      name: post.condominiumName,
      rent: post.rent,
      location: post.location,
      description: post.description,
      roomType: post.roomType,
      gender: post.gender,
      photoUrls: post.imageUrls,
      nationality: 'Any',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndividualChatScreenWithProvider(
          chatThreadId: chatThreadId,
          otherUserUid: post.userId,
          otherUserName: post.username,
          otherUserPhotoUrl: post.userProfileImageUrl,
          initialPropertyTemplate: propertyTemplate,
        ),
      ),
    );
  }

  String _generateChatThreadId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return uids.join('_');
  }

  Future<void> _launchWhatsApp(
      BuildContext context, String phone, AppLocalizations l) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.postDetail_noPhoneNumber)),
      );
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Listing'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Listing'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(_error!, style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    final post = _viewModel.post!;
    final l = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<PostActionsViewModel>.value(
      value: _viewModel,
      child: Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                post.condominiumName,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      if (post.imageUrls.isNotEmpty) _buildImageCarousel(ctx, post),
                      const SizedBox(height: 16),
                      _buildHeader(ctx, post, l),
                      const SizedBox(height: 16),
                      _buildInfoChips(post),
                      const Divider(height: 32),
                      _buildInitialCostBreakdown(ctx, post, l),
                      const Divider(height: 32),
                      _buildDescription(post, l),
                      const Divider(height: 32),
                      _buildAgentHeader(ctx, post, l),
                      const Divider(height: 32),
                      _buildAssessmentSection(ctx, post, l),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                _buildActionBar(ctx, post, l),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, PostModel post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 10,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() => _currentPage = index);
              },
            ),
            items: post.imageUrls.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Hero(
                    tag: item,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImageView(imageUrl: item),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: item,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          if (post.imageUrls.length > 1)
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(post.imageUrls.length, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, PostModel post, AppLocalizations l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.condominiumName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.placeholder_rmPerMonth(post.rent.toStringAsFixed(0)),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(PostModel post) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildInfoChip(Icons.meeting_room_outlined, post.roomType),
        _buildInfoChip(Icons.person_outline, '${post.gender} Unit'),
        if (post.durationStart != null && post.durationMonths != null)
          _buildInfoChip(
            Icons.date_range_outlined,
            '${DateFormat.yMd().format(post.durationStart!)} - ${post.durationMonths!} months',
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.deepPurple),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 102, 102, 102),
        ),
      ),
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildInitialCostBreakdown(
      BuildContext context, PostModel post, AppLocalizations l) {
    final double advanceRental = post.rent;
    final double securityDepositAmt = post.rent * post.securityDeposit;
    final double utilityDepositAmt = post.rent * post.utilityDeposit;
    final double total =
        advanceRental + securityDepositAmt + utilityDepositAmt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.deposit_breakdownTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildCostRow(l.deposit_advanceRental, advanceRental),
          _buildCostRow(
              '${l.deposit_securityDeposit} (${post.securityDeposit} ${l.deposit_mths})',
              securityDepositAmt),
          _buildCostRow(
              '${l.deposit_utilityDeposit} (${post.utilityDeposit} ${l.deposit_mths})',
              utilityDepositAmt),
          const Divider(),
          _buildCostRow(l.deposit_totalMoveInCost, total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : Colors.black87,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(PostModel post, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.postDetail_description,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          post.description.isEmpty
              ? l.postDetail_noDescription
              : post.description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentHeader(
      BuildContext context, PostModel post, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.postDetail_listedBy,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (FirebaseAuth.instance.currentUser == null) {
              showSignInModal(context);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AgentProfileScreen(agentId: post.userId),
                ),
              );
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: post.userProfileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(post.userProfileImageUrl)
                    : null,
                child: post.userProfileImageUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Posted ${timeago.format(post.timestamp.toDate())}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentSection(
      BuildContext context, PostModel post, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'AI Property Assessment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_assessment != null) ...[
            _buildAssessmentResult(_assessment!),
          ] else if (_assessmentLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_assessmentError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _assessmentError!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            )
          else
            Text(
              'See how this area fits your commute and lifestyle (AI analysis).',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          if (_assessment == null && !_assessmentLoading)
            ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      showSignInModal(context);
                      return;
                    }
                    _fetchAssessment(post);
                  },
                  icon: const Icon(Icons.directions_transit),
                  label: const Text('Get commute & area analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            ],
        ],
      ),
    );
  }

  Widget _buildAssessmentResult(PropertyAssessment a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Score: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              '${a.score}/100',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        if (a.commute != null) ...[
          const SizedBox(height: 12),
          Text(
            'Commute: ${a.commute!.duration ?? '-'} (${a.commute!.mode ?? ''})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (a.commute!.details != null && a.commute!.details!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                a.commute!.details!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
        ],
        if (a.convenience != null &&
            (a.convenience!.highlights.isNotEmpty ||
                (a.convenience!.rating != null &&
                    a.convenience!.rating!.isNotEmpty))) ...[
          const SizedBox(height: 12),
          Text(
            'Convenience: ${a.convenience!.rating ?? '-'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (a.convenience!.highlights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: a.convenience!.highlights
                    .map((h) => Chip(
                          label: Text(h, style: const TextStyle(fontSize: 12)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ),
        ],
        if (a.analysis != null) ...[
          if (a.analysis!.commute != null &&
              a.analysis!.commute!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Commute advice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a.analysis!.commute!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
          if (a.analysis!.food != null && a.analysis!.food!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Area & food',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              a.analysis!.food!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildActionBar(
      BuildContext context, PostModel post, AppLocalizations l) {
    final viewModel = context.watch<PostActionsViewModel>();
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: post.isSaved
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700],
              size: 28,
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                showSignInModal(context);
              } else {
                viewModel.savePost(post.id);
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline,
                color: Colors.grey[700], size: 28),
            tooltip: l.postDetail_commentCount,
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                showSignInModal(context);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentBottomSheet(postId: post.id),
                );
              }
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.green, size: 28),
            tooltip: l.postDetail_contactOnWhatsapp,
            onPressed: () => _launchWhatsApp(context, post.phoneNumber, l),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(WhatsappIcons.whatsapp),
              label: Text(l.postDetail_inquire),
              onPressed: () => _startChat(post),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
