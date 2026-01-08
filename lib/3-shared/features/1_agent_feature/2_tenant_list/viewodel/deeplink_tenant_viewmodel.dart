import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_detail_screen.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';

class DeepLinkTenantView extends StatefulWidget {
  final String tenantId;
  const DeepLinkTenantView({super.key, required this.tenantId});

  @override
  State<DeepLinkTenantView> createState() => _DeepLinkTenantViewState();
}

class _DeepLinkTenantViewState extends State<DeepLinkTenantView> {
  bool _isLoading = true;
  String? _error;
  UserProfile? _tenant;

  @override
  void initState() {
    super.initState();
    _loadTenant();

    // 未ログインならログインを促す
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        showSignInModal(context).then((loggedIn) {
          if (loggedIn == true) {
            setState(() {}); // リロード
          }
        });
      }
    });
  }

  Future<void> _loadTenant() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users_prof').doc(widget.tenantId).get();
      if (doc.exists) {
        _tenant = UserProfile.fromFirestore(doc);
      } else {
        setState(() => _error = "This tenant profile is no longer available.");
      }
    } catch (e) {
      setState(() => _error = "Failed to load profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenant Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TenantDetailSheetContent(tenant: _tenant!),
                  ),
                ),
    );
  }
}