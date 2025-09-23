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
    'スパム',
    '不適切なプロフィール',
    '嫌がらせ',
    'なりすまし',
    'その他',
  ];
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('ユーザーを報告', style: TextStyle(fontWeight: FontWeight.bold)),
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
            if (_selectedReason == 'その他')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _otherController,
                  decoration: const InputDecoration(
                    labelText: '理由を記入してください',
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
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          onPressed: (_selectedReason != null && _selectedReason != 'その他') ||
              (_selectedReason == 'その他' && _otherController.text.isNotEmpty)
              ? () {
            final reason = _selectedReason == 'その他'
                ? _otherController.text
                : _selectedReason;
            Navigator.of(context).pop(reason);
          }
              : null,
          child: const Text('報告する'),
        ),
      ],
    );
  }
}