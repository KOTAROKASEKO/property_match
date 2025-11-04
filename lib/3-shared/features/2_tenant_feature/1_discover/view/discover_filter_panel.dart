import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/filter_options.dart';
import '../viewmodel/discover_viewmodel.dart';

class DiscoverFilterPanel extends StatefulWidget {
  const DiscoverFilterPanel({super.key});

  @override
  State<DiscoverFilterPanel> createState() => _DiscoverFilterPanelState();
}

class _DiscoverFilterPanelState extends State<DiscoverFilterPanel> {
  // State variables from FilterBottomSheet
  late String? _gender;
  late List<String> _selectedRoomTypes;
  late TextEditingController _condoNameController;
  RangeValues _rentRange = const RangeValues(0, 5000);
  DateTime? _durationStart;
  int? _durationMonth;

  final List<String> _genderOptions = ['Male', 'Female', 'Mix', 'Any'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  late DiscoverViewModel _viewModel; // ViewModel reference

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<DiscoverViewModel>();
    _initializeFilters(_viewModel.filterOptions);
  }

  // Update UI if ViewModel filters change (e.g., cleared)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentFilters = context.watch<DiscoverViewModel>().filterOptions;
    _initializeFilters(currentFilters);
  }

  void _initializeFilters(FilterOptions filters) {
    _gender = filters.gender ?? 'Any'; // Default to 'Any' if null
    _selectedRoomTypes = filters.roomType ?? [];
    _condoNameController = TextEditingController(text: filters.condoName);
    _rentRange = RangeValues(
      filters.minRent ?? 0,
      filters.maxRent ?? 5000,
    );
    _durationStart = filters.durationStart;
    _durationMonth = filters.durationMonth;
  }

  void _applyFilters() {
    final filters = FilterOptions(
      gender: _gender == 'Any' ? null : _gender, // Send null if 'Any'
      roomType: _selectedRoomTypes.isEmpty ? null : _selectedRoomTypes,
      condoName: _condoNameController.text.trim().isEmpty
          ? null
          : _condoNameController.text.trim(),
      minRent: _rentRange.start == 0 ? null : _rentRange.start,
      maxRent: _rentRange.end == 5000 ? null : _rentRange.end,
      durationStart: _durationStart,
      durationMonth: _durationMonth,
    );
    _viewModel.applyFilters(filters);
  }

  void _clearAllFilters() {
    _viewModel.applyFilters(FilterOptions()); // Apply empty filters
    // Reset local state (will also be reset by didChangeDependencies)
    setState(() {
       _gender = 'Any';
      _selectedRoomTypes = [];
      _condoNameController.clear();
      _rentRange = const RangeValues(0, 5000);
      _durationStart = null;
      _durationMonth = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 24),
          Expanded(
            child: ListView(
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
          _buildApplyButton(),
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: _clearAllFilters,
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  // --- Apply Button ---
   Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _applyFilters,
        child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }


  // --- Helper Widgets (Copied and adjusted from FilterBottomSheet) ---

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
                labelText: 'From', // Simplified label
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(
                _durationStart != null
                    ? DateFormat.yMMMd().format(_durationStart!)
                    : 'Any Date',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Duration (Months)', // Simplified label
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              suffixText: 'months',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
          _durationMonth = int.tryParse(value);
              });
            },
          ),
        ),
      ],
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
              // Allow deselecting back to 'Any' implicitly if needed, or handle explicitly
              _gender = selected ? gender : 'Any';
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
    // This UI works well in a panel too
     return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!)
      ),
      child: Row(
        children: List.generate(_roomTypeOptions.length, (index) {
          final type = _roomTypeOptions[index];
          final isSelected = _selectedRoomTypes.contains(type);

          return Expanded(
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
          );
        }),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index) {
     const radius = Radius.circular(15); // Adjust for inner rounding
    if (index == 0) {
      return const BorderRadius.horizontal(left: radius);
    } else if (index == _roomTypeOptions.length - 1) {
      return const BorderRadius.horizontal(right: radius);
    }
    return BorderRadius.zero;
  }

  Widget _buildRentSlider() {
    // This UI works well in a panel
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
             'RM ${_rentRange.end.round() == 5000 ? "5000+" : _rentRange.end.round()}',
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
             Text('RM ${_rentRange.start.round()}'),
             Text(_rentRange.end.round() == 5000 ? "RM 5000+" : 'RM ${_rentRange.end.round()}'),
          ],
        )
      ],
    );
  }

  Widget _buildCondoNameInput() {
    // This UI works well in a panel
    return TextFormField(
      controller: _condoNameController,
      decoration: InputDecoration(
        hintText: 'Enter condominium name...',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white, // Or Colors.grey[50]
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
       onChanged: (value) {
        // No immediate action needed, applied via button
      },
    );
  }
}