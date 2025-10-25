import 'package:flutter/material.dart';

class ReportUserDialog extends StatefulWidget {
  const ReportUserDialog({super.key});

  @override
  _ReportUserDialogState createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  String? _selectedReason;
  final TextEditingController _otherController = TextEditingController();

  final List<String> _reasons = [
    'Spam',
    'Inappropriate profile',
    'Scam',
    'Phishing',
    'others',
  ];
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Report the user', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._reasons.map((reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value),
            )),
            if (_selectedReason == 'other')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _otherController,
                  decoration: const InputDecoration(
                    labelText: 'Enter the reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('cancell'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          onPressed: (_selectedReason != null && _selectedReason != 'other') ||
              (_selectedReason == 'other' && _otherController.text.isNotEmpty)
              ? () {
            final reason = _selectedReason == 'other'
                ? _otherController.text
                : _selectedReason;
            Navigator.of(context).pop(reason);
          }
              : null,
          child: const Text('Report'),
        ),
      ],
    );
  }
}