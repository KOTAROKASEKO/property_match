// lib/features/1_agent_feature/2_tenant_list/view/tenant_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tenant_filter_options.dart';

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
  late TextEditingController _nationalityController;
  late String? _gender;
  DateTime? _moveinDate;
  final _hobbyController = TextEditingController();
  late List<String> _hobbies;

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
        TextEditingController(text: widget.initialFilters.nationality);
    _gender = widget.initialFilters.gender;
    _moveinDate = widget.initialFilters.moveinDate;
    _hobbies = widget.initialFilters.hobbies ?? [];
  }

  void _applyFilters() {
    final filters = TenantFilterOptions(
      minBudget: _budgetRange.start > 0 ? _budgetRange.start : null,
      maxBudget: _budgetRange.end < 5000 ? _budgetRange.end : null,
      roomType: _roomType,
      pax: _pax,
      nationality: _nationalityController.text.trim(),
      gender: _gender,
      moveinDate: _moveinDate,
      hobbies: _hobbies,
    );
    Navigator.of(context).pop(filters);
  }

  void _clearAllFilters() {
    setState(() {
      _budgetRange = const RangeValues(0, 5000);
      _roomType = null;
      _pax = null;
      _nationalityController.clear();
      _gender = null;
      _moveinDate = null;
      _hobbies = [];
    });
    // Immediately apply cleared filters
    Navigator.of(context).pop(TenantFilterOptions());
  }

  @override
  Widget build(BuildContext context) {
    // Using a DraggableScrollableSheet for better UX on smaller screens
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    // --- Section 1: Tenancy Info ---
                    _buildSectionTitle(Icons.article_outlined, 'Tenancy Details'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMoveInDatePicker()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPaxDropdown()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Section 2: Tenant Preferences ---
                    _buildSectionTitle(Icons.tune_outlined, 'Tenant Preferences'),
                     _buildDropdown('Room Type', ['Single', 'Middle', 'Master'], _roomType, (val) => setState(() => _roomType = val)),
                    const SizedBox(height: 16),
                    _buildBudgetSlider(),
                    const SizedBox(height: 24),

                    // --- Section 3: Tenant Profile ---
                    _buildSectionTitle(Icons.person_outline, 'Tenant Profile'),
                     Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildGenderDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildNationalityInput()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHobbiesInput(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildButtonArea(),
            ],
          ),
        );
      },
    );
  }
  
  // --- WIDGET BUILDER HELPERS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

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
          setState(() => _moveinDate = pickedDate);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Move-in',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Text(_moveinDate != null ? DateFormat.yMMMd().format(_moveinDate!) : 'Any Date'),
      ),
    );
  }

  Widget _buildPaxDropdown() {
    return _buildDropdown(
      'Pax', 
      List.generate(10, (index) => (index + 1).toString()), 
      _pax?.toString(), 
      (val) => setState(() => _pax = val != null ? int.parse(val) : null)
    );
  }

  Widget _buildGenderDropdown() {
    return _buildDropdown('Gender', ['Male', 'Female', 'Mix'], _gender, (val) => setState(() => _gender = val));
  }
  
  Widget _buildNationalityInput() {
    return TextFormField(
      controller: _nationalityController,
      decoration: const InputDecoration(
        labelText: 'Nationality',
        border: OutlineInputBorder(),
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
            hintText: 'e.g., Hiking, Cooking',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                if (_hobbyController.text.trim().isNotEmpty) {
                  setState(() {
                    _hobbies.add(_hobbyController.text.trim());
                    _hobbyController.clear();
                  });
                }
              },
            ),
          ),
        ),
        if (_hobbies.isNotEmpty) const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _hobbies.map((hobby) => Chip(
                label: Text(hobby),
                onDeleted: () => setState(() => _hobbies.remove(hobby)),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _budgetRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            'RM ${_budgetRange.start.round()}',
            'RM ${_budgetRange.end.round() == 5000 ? "Any" : _budgetRange.end.round()}',
          ),
          onChanged: (values) => setState(() => _budgetRange = values),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RM ${_budgetRange.start.round()}'),
            Text(_budgetRange.end.round() == 5000 ? "RM 5000+" : 'RM ${_budgetRange.end.round()}'),
          ],
        )
      ],
    );
  }

  Widget _buildDropdown(String title, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildButtonArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
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
}