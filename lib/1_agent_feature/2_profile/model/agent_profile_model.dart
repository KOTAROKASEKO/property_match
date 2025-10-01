import 'package:cloud_firestore/cloud_firestore.dart';

class AgentProfile {
  final String uid;
  final String email;
  final String displayName;
  final String profileImageUrl;
  final String bio;

  AgentProfile({
    required this.uid,
    required this.email,
    this.displayName = 'New Agent',
    this.profileImageUrl = '',
    this.bio = '',
  });

  factory AgentProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return AgentProfile(
      uid: doc.id,
      email: data?['email'] as String? ?? '',
      displayName: data?['displayName'] as String? ?? 'New Agent',
      profileImageUrl: data?['profileImageUrl'] as String? ?? '',
      bio: data?['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }
}