import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationSlot {
  final String id;
  final String agentId;
  final DateTime startTime;
  final String status; // 'available', 'pending', 'booked'
  final String? tenantId;
  final String? tenantName;
  
  // ★ 追加フィールド
  final String? propertyName;
  final String? meetingPoint;
  final String? message;

  ReservationSlot({
    required this.id,
    required this.agentId,
    required this.startTime,
    required this.status,
    this.tenantId,
    this.tenantName,
    this.propertyName,
    this.meetingPoint,
    this.message,
  });

  factory ReservationSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReservationSlot(
      id: doc.id,
      agentId: data['agentId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'available',
      tenantId: data['tenantId'],
      tenantName: data['tenantName'],
      propertyName: data['propertyName'],
      meetingPoint: data['meetingPoint'],
      message: data['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'startTime': Timestamp.fromDate(startTime),
      'status': status,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'propertyName': propertyName,
      'meetingPoint': meetingPoint,
      'message': message,
    };
  }
}