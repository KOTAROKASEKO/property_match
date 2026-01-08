import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/3_profile/models/profile_model.dart';
import '../model/reservation_slot.dart';

class ReservationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String agentId;
  
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  List<ReservationSlot> _slots = [];
  List<ReservationSlot> get slots => _slots;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReservationViewModel(this.agentId) {
    fetchSlotsForDate(_selectedDate);
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    fetchSlotsForDate(date);
  }

  Future<void> fetchSlotsForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('reservation_slots')
          .where('agentId', isEqualTo: agentId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      _slots = snapshot.docs.map((doc) => ReservationSlot.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching slots: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- エージェント用 ---

  Future<void> openSlot(DateTime time) async {
    try {
      // 既に同じ時間のスロットがないか確認（念のため）
      final existing = _slots.where((s) => s.startTime.hour == time.hour);
      if(existing.isNotEmpty) return;

      await _firestore.collection('reservation_slots').add({
        'agentId': agentId,
        'startTime': Timestamp.fromDate(time),
        'status': 'available',
      });
      await fetchSlotsForDate(_selectedDate);
    } catch (e) {
      print("Error opening slot: $e");
    }
  }

  Future<void> closeSlot(String slotId) async {
    try {
      // トランザクションを使用して、予約が入っていない場合のみ削除
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('reservation_slots').doc(slotId);
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return;

        final status = snapshot.data()?['status'] as String?;
        // available なら削除OK。pending/booked ならエラーにするか、強制削除するか
        // ここでは安全のため available のみ削除許可とする
        if (status == 'available') {
          transaction.delete(docRef);
        } else {
          throw Exception("Cannot close a booked or pending slot directly. Use Reject/Cancel.");
        }
      });
      await fetchSlotsForDate(_selectedDate);
    } catch (e) {
      print("Error closing slot: $e");
      rethrow; // UI側でエラー表示するために再スロー
    }
  }

  // ★ 追加: 予約リクエストを承認する
  Future<void> approveReservation(String slotId) async {
    try {
      await _firestore.collection('reservation_slots').doc(slotId).update({
        'status': 'booked',
      });
      await fetchSlotsForDate(_selectedDate);
    } catch (e) {
      print("Error approving reservation: $e");
    }
  }

  // ★ 追加: 予約リクエストを拒否する
  Future<void> rejectReservation(String slotId) async {
    // リクエスト情報を消して Available に戻す
    await cancelReservationByAgent(slotId);
  }

  Future<void> cancelReservationByAgent(String slotId) async {
    try {
      await _firestore.collection('reservation_slots').doc(slotId).update({
        'status': 'available',
        'tenantId': FieldValue.delete(),
        'tenantName': FieldValue.delete(),
        'propertyName': FieldValue.delete(),
        'meetingPoint': FieldValue.delete(),
        'message': FieldValue.delete(),
      });
      await fetchSlotsForDate(_selectedDate);
    } catch (e) {
      print("Error canceling reservation: $e");
    }
  }

  // --- テナント用 ---

  // ★ 修正: 予約リクエストを送る（トランザクション使用）
  Future<void> requestBooking({
    required String slotId,
    required UserProfile tenant,
    required String propertyName,
    required String meetingPoint,
    String? message,
  }) async {
    final docRef = _firestore.collection('reservation_slots').doc(slotId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception("This slot is no longer available (closed by agent).");
        }

        final status = snapshot.data()?['status'] as String?;
        if (status != 'available') {
          throw Exception("This slot has already been taken.");
        }

        // ステータスを pending に更新
        transaction.update(docRef, {
          'status': 'pending',
          'tenantId': tenant.uid,
          'tenantName': tenant.displayName,
          'propertyName': propertyName,
          'meetingPoint': meetingPoint,
          'message': message ?? '',
        });
      });
      await fetchSlotsForDate(_selectedDate);
    } catch (e) {
      print("Error requesting booking: $e");
      rethrow; // UIでSnackbarを出すために再スロー
    }
  }

  // 自分のリクエスト/予約をキャンセル
  Future<void> cancelMyReservation(String slotId) async {
    await cancelReservationByAgent(slotId);
  }
}