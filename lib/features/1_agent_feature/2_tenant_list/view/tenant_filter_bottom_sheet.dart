// lib/features/1_agent_feature/2_tenant_list/view/tenant_filter_bottom_sheet.dart

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _budgetRange = RangeValues(
      widget.initialFilters.minBudget ?? 0,
      widget.initialFilters.maxBudget ?? 5000,
    );
    _roomType = widget.initialFilters.roomType;
    _pax = widget.initialFilters.pax;
  }

  @override
  Widget build(BuildContext context) {
    // This robust structure handles keyboard visibility and scrolling.
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Title and Clear Button)
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
                    });
                  },
                  child: const Text('Clear All'),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Budget Range Slider
            Text(
                'Budget Range (RM): ${_budgetRange.start.round()} - ${_budgetRange.end.round() == 5000 ? "Any" : _budgetRange.end.round()}'),
            RangeSlider(
              values: _budgetRange,
              min: 0,
              max: 5000,
              divisions: 50, // 100 increments
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

            // Room Type Dropdown
            _buildDropdown('Room Type', ['Single', 'Middle', 'Master'],
                _roomType, (val) => setState(() => _roomType = val)),
            const SizedBox(height: 16),

            // Pax Dropdown
            _buildDropdown(
                'Pax (Number of People)',
                List.generate(10, (index) => (index + 1).toString()),
                _pax?.toString(),
                (val) =>
                    setState(() => _pax = val != null ? int.parse(val) : null)),
            const SizedBox(height: 24),

            // Apply Button
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

  // Helper widget for creating dropdowns
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