import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/tenant_filter_options.dart';

class TenantFilterBottomSheet extends StatefulWidget {
  final TenantFilterOptions initialFilters;

  const TenantFilterBottomSheet({super.key, required this.initialFilters});

  @override
  _TenantFilterBottomSheetState createState() => _TenantFilterBottomSheetState();
}

class _TenantFilterBottomSheetState extends State<TenantFilterBottomSheet> {
  late RangeValues _budgetRange;
  late String? _roomType;
  late int? _pax;
  late TextEditingController _nationalityController;
  late String? _gender;
  DateTime? _moveinDate;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master', 'Studio'];

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
      // hobbies は削除済み
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
    });
    Navigator.of(context).pop(TenantFilterOptions());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      // キーボード表示時に隠れないようにPaddingを追加
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          // ドラッグ用ハンドル
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                _buildSectionCard(
                  icon: Icons.article_outlined,
                  title: 'Tenancy Details',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMoveInDatePicker()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPaxDropdown()),
                      ],
                    ),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.tune_outlined,
                  title: 'Tenant Preferences',
                  children: [
                    const Text("Room Type", style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildRoomTypeChips(),
                    const SizedBox(height: 24),
                    const Text("Budget Range", style: TextStyle(fontWeight: FontWeight.w500)),
                    _buildBudgetSlider(),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.person_outline,
                  title: 'Tenant Profile',
                  children: [
                    const Text("Gender", style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildGenderChips(),
                    const SizedBox(height: 16),
                    _buildNationalityInput(),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildButtonArea(),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeChips() {
    return Wrap(
      spacing: 8.0,
      children: _roomTypeOptions.map((type) {
        final isSelected = _roomType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _roomType = selected ? type : null;
            });
          },
          selectedColor: Colors.deepPurple,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenderChips() {
    return Wrap(
      spacing: 8.0,
      children: _genderOptions.map((gender) {
        final isSelected = _gender == gender;
        return ChoiceChip(
          label: Text(gender),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _gender = selected ? gender : null;
            });
          },
          selectedColor: Colors.deepPurple,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
          ),
        );
      }).toList(),
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
        decoration: InputDecoration(
          labelText: 'Move-in',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _moveinDate != null ? DateFormat.yMMMd().format(_moveinDate!) : 'Any Date',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPaxDropdown() {
    return DropdownButtonFormField<String>(
      value: _pax?.toString(),
      decoration: InputDecoration(
        labelText: 'Pax',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
      items: List.generate(10, (index) => (index + 1).toString())
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (val) => setState(() => _pax = val != null ? int.parse(val) : null),
    );
  }

  Widget _buildNationalityInput() {
    return TextFormField(
      controller: _nationalityController,
      decoration: InputDecoration(
        labelText: 'Nationality',
        hintText: 'e.g. Japanese',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
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
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.deepPurple.withOpacity(0.2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RM ${_budgetRange.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_budgetRange.end.round() == 5000 ? "RM 5000+" : 'RM ${_budgetRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
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
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _applyFilters,
        child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}