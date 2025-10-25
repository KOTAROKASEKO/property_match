// lib/features/2_tenant_feature/1_discover/view/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _gender;
  late List<String> _selectedRoomTypes;
  late TextEditingController _condoNameController;
  RangeValues _rentRange = const RangeValues(0, 5000);
  DateTime? _durationStart;
  DateTime? _durationEnd;

  final List<String> _genderOptions = ['Male', 'Female', 'Mix', 'Any'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  @override
  void initState() {
    super.initState();
    _gender = widget.initialFilters.gender;
    _selectedRoomTypes = widget.initialFilters.roomType ?? [];
    _condoNameController =
        TextEditingController(text: widget.initialFilters.condoName);
    _rentRange = RangeValues(
      widget.initialFilters.minRent ?? 0,
      widget.initialFilters.maxRent ?? 5000,
    );
    _durationStart = widget.initialFilters.durationStart;
    _durationEnd = widget.initialFilters.durationEnd;
  }

  void _clearAllFilters() {
    setState(() {
      _gender = null;
      _selectedRoomTypes = [];
      _condoNameController.clear();
      _rentRange = const RangeValues(0, 5000);
      _durationStart = null;
      _durationEnd = null;
    });
    // Immediately apply the cleared filters by popping with new empty options
    Navigator.pop(context, FilterOptions());
  }


  void _applyFilters() {
    final filters = FilterOptions(
      gender: _gender,
      roomType: _selectedRoomTypes,
      condoName: _condoNameController.text.trim().isEmpty
          ? null
          : _condoNameController.text.trim(),
      minRent: _rentRange.start == 0 ? null : _rentRange.start,
      maxRent: _rentRange.end == 5000 ? null : _rentRange.end,
      durationStart: _durationStart,
      durationEnd: _durationEnd,
    );
    Navigator.of(context).pop(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // ヘッダー
          _buildHeader(),
          
          // コンテンツ
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Available between'),
                  _buildDateRangePicker(context),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Gender'),
                  _buildGenderChips(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Room Type'),
                  _buildRoomTypeToggle(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Rent Range (RM)'),
                  _buildRentSlider(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Condominium Name'),
                  _buildCondoNameInput(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // ボタンエリア
          _buildButtonArea(),
        ],
      ),
    );
  }

  // --- Widgets Builder ---

  Widget _buildDateRangePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _durationStart ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  _durationStart = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Available From',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(
                _durationStart != null
                    ? DateFormat.yMMMd().format(_durationStart!)
                    : 'Any',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _durationEnd ?? _durationStart ?? DateTime.now(),
                firstDate: _durationStart ?? DateTime(2020),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  _durationEnd = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Available To',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(
                _durationEnd != null
                    ? DateFormat.yMMMd().format(_durationEnd!)
                    : 'Any',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildGenderChips() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _genderOptions.map((gender) {
        final isSelected = _gender == gender;
        return FilterChip(
          label: Text(
            gender,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _gender = selected ? gender : null;
            });
          },
          backgroundColor: Colors.grey[50],
          selectedColor: Colors.deepPurple,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: isSelected ? 0 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildRoomTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_roomTypeOptions.length, (index) {
          final type = _roomTypeOptions[index];
          final isSelected = _selectedRoomTypes.contains(type);
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 1,
                right: index == _roomTypeOptions.length - 1 ? 0 : 1,
              ),
              child: Material(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                borderRadius: _getBorderRadius(index),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedRoomTypes.contains(type)) {
                        _selectedRoomTypes.remove(type);
                      } else {
                        _selectedRoomTypes.add(type);
                      }
                    });
                  },
                  borderRadius: _getBorderRadius(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index) {
    if (index == 0) {
      return const BorderRadius.horizontal(left: Radius.circular(16));
    } else if (index == _roomTypeOptions.length - 1) {
      return const BorderRadius.horizontal(right: Radius.circular(16));
    }
    return BorderRadius.zero;
  }

  Widget _buildRentSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _rentRange,
          min: 0,
          max: 5000,
          divisions: 50,
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.deepPurple[100],
          labels: RangeLabels(
            'RM ${_rentRange.start.round()}',
            'RM ${_rentRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _rentRange = values;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'RM ${_rentRange.start.round()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'RM ${_rentRange.end.round()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCondoNameInput() {
    return TextFormField(
      controller: _condoNameController,
      decoration: InputDecoration(
        hintText: 'Enter condominium name...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildButtonArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: _applyFilters,
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}