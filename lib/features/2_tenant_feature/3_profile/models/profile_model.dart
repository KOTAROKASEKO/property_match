import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String profileImageUrl;
  final int age;
  final String occupation;
  final String location;
  final String pets; // "Yes", "No"
  final int pax; // Number of people
  final double budget;
  final String roomType; // "Single", "Middle", "Master"
  final String propertyType; // "Condo", "Landed", "Apartment"
  final String nationality;
  final String selfIntroduction;
  final DateTime? moveinDate;
  final String gender; // ★★★ 追加 ★★★

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName = 'New User',
    this.profileImageUrl = '',
    this.age = 25,
    this.occupation = 'Not specified',
    this.location = 'Not specified',
    this.pets = 'No',
    this.pax = 1,
    this.budget = 1000.0,
    this.roomType = 'Middle',
    this.propertyType = 'Condominium',
    this.nationality = 'Not specified',
    this.selfIntroduction = '',
    this.moveinDate,
    this.gender = 'Not specified', // ★★★ 追加 (デフォルト値設定) ★★★
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserProfile(
      uid: doc.id,
      email: data?['email'] as String? ?? '',
      displayName: data?['displayName'] as String? ?? 'New User',
      profileImageUrl: data?['profileImageUrl'] as String? ?? '',
      age: data?['age'] as int? ?? 25,
      occupation: data?['occupation'] as String? ?? 'Not specified',
      location: data?['location'] as String? ?? 'Not specified',
      pets: data?['pets'] as String? ?? 'No',
      pax: data?['pax'] as int? ?? 1,
      budget: (data?['budget'] as num?)?.toDouble() ?? 1000.0,
      roomType: data?['roomType'] as String? ?? 'Middle',
      propertyType: data?['propertyType'] as String? ?? 'Condominium',
      nationality: data?['nationality'] as String? ?? 'Not specified',
      selfIntroduction: data?['selfIntroduction'] as String? ?? '',
      moveinDate: (data?['moveinDate'] as Timestamp?)?.toDate(),
      gender: data?['gender'] as String? ?? 'Not specified', // ★★★ 追加 ★★★
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'occupation': occupation,
      'location': location,
      'pets': pets,
      'pax': pax,
      'budget': budget,
      'roomType': roomType,
      'propertyType': propertyType,
      'nationality': nationality,
      'selfIntroduction': selfIntroduction,
      'moveinDate': moveinDate != null ? Timestamp.fromDate(moveinDate!) : null,
      'gender': gender, // ★★★ 追加 ★★★
    };
  }
}