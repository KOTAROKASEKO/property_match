// lib/2_tenant_feature/4_chat/view/date_time_picker_modal.dart

import 'package:flutter/material.dart';

class DateTimePickerModal extends StatefulWidget {
  const DateTimePickerModal({super.key});

  @override
  _DateTimePickerModalState createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // 過去の日時が選択されないよう、初期値を調整
    final now = DateTime.now();
    _selectedDate =
        now.hour >= 23 ? now.add(const Duration(days: 1)) : now;
    _selectedTime =
        TimeOfDay(hour: now.hour + 1, minute: now.minute);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() {
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    Navigator.of(context).pop(selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Select Viewing Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                  "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            ListTile(
              title: Text("Time: ${_selectedTime.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _submit,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}