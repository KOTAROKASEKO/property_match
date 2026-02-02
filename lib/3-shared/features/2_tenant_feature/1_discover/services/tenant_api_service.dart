// lib/3-shared/features/2_tenant_feature/1_discover/services/tenant_api_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Base URL for bilikmatch-tenant Next.js API (production).
const String _tenantApiBase = 'https://bilikmatch.com';

/// API client for bilikmatch-tenant endpoints: analytics and property assessment.
class TenantApiService {
  /// Records a detail view for the given post (analytics).
  /// No auth required.
  static Future<void> recordDetailView(String postId) async {
    final uri = Uri.parse('$_tenantApiBase/api/analytics/detail-view');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'postId': postId}),
    );
    if (res.statusCode != 200) {
      // Non-blocking: log but don't throw
      return;
    }
  }

  /// Fetches AI property assessment from bilikmatch-tenant.
  /// Requires Firebase Auth; returns null if not logged in or on error.
  static Future<PropertyAssessment?> fetchAssess({
    required String propertyId,
    String? propertyLocation,
    String? lang,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    String? token;
    try {
      token = await user.getIdToken(true);
    } catch (_) {
      return null;
    }
    if (token == null) return null;

    final uri = Uri.parse('$_tenantApiBase/api/revalidate/assess');
    final body = <String, dynamic>{
      'propertyId': propertyId,
      if (propertyLocation != null && propertyLocation.isNotEmpty) 'propertyLocation': propertyLocation,
      if (lang != null && lang.isNotEmpty) 'lang': lang,
    };
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      final error = map?['error'] as String? ?? res.body;
      throw TenantApiException(error, res.statusCode);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final success = data['success'] as bool? ?? false;
    final dataPayload = data['data'] as Map<String, dynamic>?;
    if (!success || dataPayload == null) return null;
    return PropertyAssessment.fromJson(dataPayload);
  }
}

class TenantApiException implements Exception {
  final String message;
  final int statusCode;
  TenantApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

/// Response model for /api/revalidate/assess.
class PropertyAssessment {
  final int score;
  final CommuteInfo? commute;
  final ConvenienceInfo? convenience;
  final AnalysisInfo? analysis;

  const PropertyAssessment({
    required this.score,
    this.commute,
    this.convenience,
    this.analysis,
  });

  factory PropertyAssessment.fromJson(Map<String, dynamic> json) {
    return PropertyAssessment(
      score: (json['score'] as num?)?.toInt() ?? 0,
      commute: json['commute'] != null
          ? CommuteInfo.fromJson(json['commute'] as Map<String, dynamic>)
          : null,
      convenience: json['convenience'] != null
          ? ConvenienceInfo.fromJson(json['convenience'] as Map<String, dynamic>)
          : null,
      analysis: json['analysis'] != null
          ? AnalysisInfo.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CommuteInfo {
  final String? origin;
  final String? destination;
  final String? duration;
  final String? mode;
  final String? details;

  CommuteInfo({
    this.origin,
    this.destination,
    this.duration,
    this.mode,
    this.details,
  });

  factory CommuteInfo.fromJson(Map<String, dynamic> json) {
    return CommuteInfo(
      origin: json['origin'] as String?,
      destination: json['destination'] as String?,
      duration: json['duration'] as String?,
      mode: json['mode'] as String?,
      details: json['details'] as String?,
    );
  }
}

class ConvenienceInfo {
  final String? rating;
  final List<String> highlights;

  ConvenienceInfo({this.rating, this.highlights = const []});

  factory ConvenienceInfo.fromJson(Map<String, dynamic> json) {
    final list = json['highlights'];
    return ConvenienceInfo(
      rating: json['rating'] as String?,
      highlights: list is List ? list.map((e) => e.toString()).toList() : [],
    );
  }
}

class AnalysisInfo {
  final String? commute;
  final String? food;

  AnalysisInfo({this.commute, this.food});

  factory AnalysisInfo.fromJson(Map<String, dynamic> json) {
    return AnalysisInfo(
      commute: json['commute'] as String?,
      food: json['food'] as String?,
    );
  }
}
