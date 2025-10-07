// lib/2_tenant_feature/2_discover/view/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:re_conver/features/2_tenant_feature/1_discover/model/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _gender;
  late List<String> _selectedRoomTypes; // Changed from String?
  late TextEditingController _condoNameController;
  RangeValues _rentRange = const RangeValues(0, 5000);

  @override
  void initState() {
    super.initState();
    _gender = widget.initialFilters.gender;
    _selectedRoomTypes = widget.initialFilters.roomType ?? []; // Initialize as a list
    _condoNameController =
        TextEditingController(text: widget.initialFilters.condoName);
    _rentRange = RangeValues(
      widget.initialFilters.minRent ?? 0,
      widget.initialFilters.maxRent ?? 5000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _gender = null;
                    _selectedRoomTypes = []; // Clear the list
                    _condoNameController.clear();
                    _rentRange = const RangeValues(0, 5000);
                  });
                },
                child: const Text('Clear All'),
              )
            ],
          ),
          const SizedBox(height: 24),
          _buildDropdown('Gender', ['Male', 'Female', 'Mix','Any'], _gender,
              (val) => setState(() => _gender = val)),
          const SizedBox(height: 16),
          // Room Type multi-select
          const Text('Room Type', style: TextStyle(fontWeight: FontWeight.bold)),
          ...['Single', 'Middle', 'Master'].map((roomType) {
            return CheckboxListTile(
              title: Text(roomType),
              value: _selectedRoomTypes.contains(roomType),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedRoomTypes.add(roomType);
                  } else {
                    _selectedRoomTypes.remove(roomType);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _condoNameController,
            decoration: const InputDecoration(labelText: 'Condominium Name'),
          ),
          const SizedBox(height: 24),
          const Text('Rent Range (RM)'),
          RangeSlider(
            values: _rentRange,
            min: 0,
            max: 5000,
            divisions: 50,
            labels: RangeLabels(
              _rentRange.start.round().toString(),
              _rentRange.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _rentRange = values;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              final filters = FilterOptions(
                gender: _gender,
                roomType: _selectedRoomTypes, // Pass the list
                condoName: _condoNameController.text,
                minRent: _rentRange.start,
                maxRent: _rentRange.end,
              );
              Navigator.of(context).pop(filters);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String title, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: title),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}