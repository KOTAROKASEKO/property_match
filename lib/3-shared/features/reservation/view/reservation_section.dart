import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart';
import '../../../features/2_tenant_feature/3_profile/models/profile_model.dart';
import '../../../features/2_tenant_feature/3_profile/services/user_service.dart';
import '../viewmodel/reservation_viewmodel.dart';
import '../model/reservation_slot.dart';

class ReservationSection extends StatefulWidget {
  final String agentId;
  final bool isAgentView; 

  const ReservationSection({
    super.key,
    required this.agentId,
    required this.isAgentView,
  });

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  final List<int> _hours = List.generate(9, (index) => 10 + index);
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (userData.userId.isNotEmpty) {
      try {
        final profile = await UserService().getUserProfile();
        if (mounted) setState(() => _currentUserProfile = profile);
      } catch (e) {
        print("Error loading user profile: $e");
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReservationViewModel(widget.agentId),
      child: Consumer<ReservationViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isAgentView ? "Manage Viewing Slots" : "Book a Viewing",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // 1. Date Selector
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 14, // 2週間分くらい見れるように拡張
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = isSameDay(date, viewModel.selectedDate);
                      
                      return GestureDetector(
                        onTap: () => viewModel.selectDate(date),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.grey.shade300
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(date),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),

                // 2. Time Slots
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _hours.map((hour) {
                          final slotTime = DateTime(
                            viewModel.selectedDate.year,
                            viewModel.selectedDate.month,
                            viewModel.selectedDate.day,
                            hour,
                          );

                          final existingSlot = viewModel.slots.firstWhere(
                            (s) => s.startTime.hour == hour,
                            orElse: () => ReservationSlot(
                              id: '', 
                              agentId: widget.agentId,
                              startTime: slotTime,
                              status: 'none', 
                            ),
                          );

                          return _buildSlotChip(context, viewModel, existingSlot, slotTime);
                        }).toList(),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotChip(
    BuildContext context,
    ReservationViewModel viewModel,
    ReservationSlot slot,
    DateTime slotTime,
  ) {
    bool exists = slot.status != 'none';
    bool isBooked = slot.status == 'booked';
    bool isPending = slot.status == 'pending'; // ★ Pending状態
    bool isMyBooking = slot.tenantId == userData.userId;

    Color bgColor = Colors.grey.shade200;
    Color textColor = Colors.black;
    String label = "${slotTime.hour}:00";

    if (widget.isAgentView) {
      // --- エージェント視点 ---
      if (!exists) {
        bgColor = Colors.white; 
        textColor = Colors.grey;
      } else if (isBooked) {
        bgColor = Colors.deepOrange.shade100;
        textColor = Colors.deepOrange;
        label += "\nBooked";
      } else if (isPending) {
        // ★ 承認待ち
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        label += "\nRequest";
      } else {
        // Available
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label += "\nOpen";
      }
    } else {
      // --- テナント視点 ---
      if (!exists) {
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade400;
      } else if (isBooked) {
        if (isMyBooking) {
          bgColor = Colors.blue.shade100;
          textColor = Colors.blue.shade800;
          label += "\nConfirmed";
        } else {
          bgColor = Colors.grey.shade300;
          textColor = Colors.grey;
          label += "\nTaken";
        }
      } else if (isPending) {
        if (isMyBooking) {
          bgColor = Colors.amber.shade100;
          textColor = Colors.amber.shade900;
          label += "\nPending";
        } else {
          // 他人のペンディングは「取られている」ように見せるか、Pendingと出すか
          bgColor = Colors.grey.shade300;
          textColor = Colors.grey;
          label += "\nTaken";
        }
      } else {
        // Available
        bgColor = Colors.white;
        textColor = Colors.deepPurple;
      }
    }

    return InkWell(
      onTap: () => _handleSlotTap(context, viewModel, slot, slotTime, exists, isBooked, isPending, isMyBooking),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: (!exists && !widget.isAgentView) 
              ? null
              : Border.all(color: Colors.grey.shade300),
          boxShadow: (!widget.isAgentView && exists && !isBooked && !isPending)
              ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleSlotTap(
    BuildContext context,
    ReservationViewModel viewModel,
    ReservationSlot slot,
    DateTime slotTime,
    bool exists,
    bool isBooked,
    bool isPending,
    bool isMyBooking,
  ) {
    if (widget.isAgentView) {
      // --- エージェント操作 ---
      if (!exists) {
        viewModel.openSlot(slotTime);
      } else if (isPending) {
        // ★ リクエスト承認ダイアログ
        _showApprovalDialog(context, viewModel, slot);
      } else if (isBooked) {
        // 予約済み -> 詳細/キャンセル
        _showAgentCancelDialog(context, viewModel, slot);
      } else {
        // Available -> 閉じる
        _closeSlotSafely(context, viewModel, slot);
      }
    } else {
      // --- テナント操作 ---
      if (!exists) return; 

      if (!isBooked && !isPending) {
        // ★ 予約リクエストフォームを表示
        if (_currentUserProfile == null) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to book.")));
           return;
        }
        _showBookingForm(context, viewModel, slot.id, slotTime);

      } else if (isMyBooking) {
        // 自分の予約/リクエストをキャンセル
        String statusText = isPending ? "Request" : "Booking";
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Cancel $statusText"),
            content: Text("Do you want to cancel your $statusText?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep")),
              TextButton(
                onPressed: () {
                  viewModel.cancelMyReservation(slot.id);
                  Navigator.pop(context);
                },
                child: const Text("Cancel It", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    }
  }

  // --- ダイアログ関連 ---

  void _closeSlotSafely(BuildContext context, ReservationViewModel viewModel, ReservationSlot slot) async {
    try {
      await viewModel.closeSlot(slot.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot close: Slot may be booked by someone just now.")),
      );
    }
  }

  void _showAgentCancelDialog(BuildContext context, ReservationViewModel viewModel, ReservationSlot slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Booking Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tenant: ${slot.tenantName ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Property: ${slot.propertyName ?? 'Not specified'}"),
            Text("Meeting: ${slot.meetingPoint ?? 'Not specified'}"),
            if (slot.message != null && slot.message!.isNotEmpty)
              Text("Msg: ${slot.message}"),
            const SizedBox(height: 16),
            const Text("Do you want to cancel this reservation?", style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          TextButton(
            onPressed: () {
              viewModel.cancelReservationByAgent(slot.id);
              Navigator.pop(context);
            },
            child: const Text("Cancel Reservation", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, ReservationViewModel viewModel, ReservationSlot slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Request!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tenant: ${slot.tenantName ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Property: ${slot.propertyName ?? 'Not specified'}"),
            Text("Meeting: ${slot.meetingPoint ?? 'Not specified'}"),
            if (slot.message != null && slot.message!.isNotEmpty)
              Text("Msg: ${slot.message}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.rejectReservation(slot.id);
              Navigator.pop(context);
            },
            child: const Text("Reject", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.approveReservation(slot.id);
              Navigator.pop(context);
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  void _showBookingForm(BuildContext context, ReservationViewModel viewModel, String slotId, DateTime slotTime) {
    final propertyController = TextEditingController();
    final meetingController = TextEditingController();
    final msgController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, 
          left: 16, right: 16, top: 16
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Request Viewing: ${DateFormat('MMM d, h:00 a').format(slotTime)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: propertyController,
                decoration: const InputDecoration(labelText: 'Property Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: meetingController,
                decoration: const InputDecoration(labelText: 'Preferred Meeting Point *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: msgController,
                decoration: const InputDecoration(labelText: 'Message (Optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await viewModel.requestBooking(
                          slotId: slotId,
                          tenant: _currentUserProfile!,
                          propertyName: propertyController.text,
                          meetingPoint: meetingController.text,
                          message: msgController.text,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Request sent! Waiting for agent approval.")),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Send Request"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}