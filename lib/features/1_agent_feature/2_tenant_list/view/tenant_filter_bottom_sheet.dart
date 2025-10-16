// lib/features/1_agent_feature/2_tenant_list/view/tenant_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/features/1_agent_feature/2_tenant_list/model/tenant_filter_options.dart';

class TenantFilterBottomSheet extends StatefulWidget {
  final TenantFilterOptions initialFilters;

  const TenantFilterBottomSheet({super.key, required this.initialFilters});

  @override
  _TenantFilterBottomSheetState createState() =>
      _TenantFilterBottomSheetState();
}

class _TenantFilterBottomSheetState extends State<TenantFilterBottomSheet> {
  late RangeValues _budgetRange;
  late String? _roomType;
  late int? _pax;
  late TextEditingController _nationalityController; // ★ 追加
  late String? _gender; // ★ 追加
  DateTime? _moveinDate; // ★ 追加
  final _hobbyController = TextEditingController(); // Added hobby controller
  late List<String> _hobbies; // Added hobbies

  @override
  void initState() {
    super.initState();
    _budgetRange = RangeValues(
      widget.initialFilters.minBudget ?? 0,
      widget.initialFilters.maxBudget ?? 5000,
    );
    _roomType = widget.initialFilters.roomType;
    _pax = widget.initialFilters.pax;
    _nationalityController =
        TextEditingController(text: widget.initialFilters.nationality); // ★ 追加
    _gender = widget.initialFilters.gender; // ★ 追加
    _moveinDate = widget.initialFilters.moveinDate; // ★ 追加
    _hobbies = widget.initialFilters.hobbies ?? []; // Added hobbies
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _budgetRange = const RangeValues(0, 5000);
                      _roomType = null;
                      _pax = null;
                      _nationalityController.clear(); // ★ 追加
                      _gender = null; // ★ 追加
                      _moveinDate = null; // ★ 追加
                      _hobbies = []; // Added hobbies
                    });
                  },
                  child: const Text('Clear All'),
                )
              ],
            ),
            const SizedBox(height: 24),

            // ★★★ Move-in Date Picker ★★★
            _buildMoveInDatePicker(),
            const SizedBox(height: 16),
            _buildHobbiesInput(),
            const SizedBox(height: 16),

            // ★★★ 国籍入力フィールドを追加 ★★★
            TextFormField(
              controller: _nationalityController,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ★★★ 性別選択ドロップダウンを追加 ★★★
            _buildDropdown('Gender', ['Male', 'Female', 'Mix'], _gender,
                (val) => setState(() => _gender = val)),
            const SizedBox(height: 16),

            Text(
                'Budget Range (RM): ${_budgetRange.start.round()} - ${_budgetRange.end.round() == 5000 ? "Any" : _budgetRange.end.round()}'),
            RangeSlider(
              values: _budgetRange,
              min: 0,
              max: 5000,
              divisions: 50,
              labels: RangeLabels(
                _budgetRange.start.round().toString(),
                _budgetRange.end.round() == 5000
                    ? "Any"
                    : _budgetRange.end.round().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  _budgetRange = values;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdown('Room Type', ['Single', 'Middle', 'Master'],
                _roomType, (val) => setState(() => _roomType = val)),
            const SizedBox(height: 16),

            _buildDropdown(
                'Pax (Number of People)',
                List.generate(10, (index) => (index + 1).toString()),
                _pax?.toString(),
                (val) =>
                    setState(() => _pax = val != null ? int.parse(val) : null)),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final filters = TenantFilterOptions(
                  minBudget: _budgetRange.start,
                  maxBudget: _budgetRange.end,
                  roomType: _roomType,
                  pax: _pax,
                  nationality: _nationalityController.text,
                  gender: _gender,
                  moveinDate: _moveinDate,
                  hobbies: _hobbies, // Added
                );
                Navigator.of(context).pop(filters);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _hobbyController,
          decoration: InputDecoration(
            labelText: 'Hobbies',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_hobbyController.text.isNotEmpty) {
                  setState(() {
                    _hobbies.add(_hobbyController.text);
                    _hobbyController.clear();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _hobbies
              .map((hobby) => Chip(
                    label: Text(hobby),
                    onDeleted: () {
                      setState(() {
                        _hobbies.remove(hobby);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ★★★ Function to build the move-in date picker ★★★
  Widget _buildMoveInDatePicker() {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _moveinDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _moveinDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Move-in Date',
          border: OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Text(
          _moveinDate != null
              ? DateFormat.yMMMd().format(_moveinDate!)
              : 'Any',
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}