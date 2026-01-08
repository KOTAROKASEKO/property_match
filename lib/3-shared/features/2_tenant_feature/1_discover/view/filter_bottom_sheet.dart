import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_layout.dart';
import 'package:re_conver/l10n/app_localizations.dart';
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
  late TextEditingController _semanticQueryController;
  RangeValues _rentRange = const RangeValues(0, 5000);
  DateTime? _durationStart;
  int? _durationMonth;
  final _hobbyController = TextEditingController();
  late List<String> _hobbies;

  final List<String> _genderOptions = ['Male', 'Female', 'Mix', 'Any'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  @override
  void initState() {
    super.initState();
    _gender = widget.initialFilters.gender;
    _selectedRoomTypes = widget.initialFilters.roomType ?? [];
    _semanticQueryController =
        TextEditingController(text: widget.initialFilters.semanticQuery);
    _rentRange = RangeValues(
      widget.initialFilters.minRent ?? 0,
      widget.initialFilters.maxRent ?? 5000,
    );
    _durationStart = widget.initialFilters.durationStart;
    _durationMonth = widget.initialFilters.durationMonth;
    _hobbies = widget.initialFilters.hobbies ?? [];
  }

  void _clearAllFilters() {
    setState(() {
      _gender = null;
      _selectedRoomTypes = [];
      _semanticQueryController.clear();
      _rentRange = const RangeValues(0, 5000);
      _durationStart = null;
      _durationMonth = null;
      _hobbies = [];
      _hobbyController.clear();
    });
    Navigator.pop(context, FilterOptions());
  }

  void _applyFilters() {
    final filters = FilterOptions(
      gender: _gender,
      roomType: _selectedRoomTypes,
      semanticQuery: _semanticQueryController.text.trim().isEmpty
          ? null
          : _semanticQueryController.text.trim(),
      minRent: _rentRange.start == 0 ? null : _rentRange.start,
      maxRent: _rentRange.end == 5000 ? null : _rentRange.end,
      durationStart: _durationStart,
      durationMonth: _durationMonth,
      hobbies: _hobbies.isEmpty ? null : _hobbies,
    );
    Navigator.of(context).pop(filters);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(l),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    icon: Icons.auto_awesome,
                    title: l.discover_aiSearchAssistant,
                    children: [
                      _buildAIChatButton(context, l),
                    ],
                  ),
                  _buildSectionCard(
                    icon: Icons.calendar_today_outlined,
                    title: l.discover_availability,
                    children: [
                      _buildDateRangePicker(context, l),
                    ],
                  ),
                  _buildSectionCard(
                    icon: Icons.home_outlined,
                    title: l.discover_propertyDetails,
                    children: [
                      Text(l.discover_gender,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildGenderChips(),
                      const SizedBox(height: 16),
                      Text(l.discover_roomType,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildRoomTypeToggle(),
                    ],
                  ),
                  _buildSectionCard(
                    icon: Icons.attach_money_outlined,
                    title: l.discover_rentRange,
                    children: [
                      _buildRentSlider(),
                    ],
                  ),
                  _buildSectionCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Atmosphere / Keywords',
                    children: [
                      _buildSemanticQueryInput(),
                    ],
                  ),
                  _buildSectionCard(
                    icon: Icons.pool_outlined,
                    title: 'Hobbies & Lifestyle',
                    children: [
                      _buildHobbiesInput(),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildButtonArea(l),
        ],
      ),
    );
  }

  Widget _buildAIChatButton(BuildContext context, AppLocalizations l) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.chat_outlined, size: 18),
      label: Text(l.discover_tryMe),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade50,
        foregroundColor: Colors.deepPurple.shade700,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        final aiFilters = await Navigator.push<FilterOptions>(
          context,
          MaterialPageRoute(builder: (_) => const AIChatMainLayout()),
        );

        if (aiFilters != null && context.mounted) {
          Navigator.of(context).pop(aiFilters);
        }
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, AppLocalizations l) {
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
                labelText: 'From',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(
                _durationStart != null
                    ? DateFormat.yMMMd().format(_durationStart!)
                    : l.discover_anyDate,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _durationMonth?.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.discover_durationMonths,
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _durationMonth = int.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l.deposit_mths,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l) {
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
          Text(
            l.discover_filtersTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              l.discover_clearAll,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  Widget _buildSemanticQueryInput() {
    return TextFormField(
      controller: _semanticQueryController,
      decoration: InputDecoration(
        hintText: 'e.g., "sunny", "stylish furniture"',
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
        prefixIcon:
            Icon(Icons.auto_awesome_outlined, color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildHobbiesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onFieldSubmitted: (value) {
            final hobby = value.trim().toLowerCase();
            if (hobby.isNotEmpty) {
              setState(() {
                if (!_hobbies.contains(hobby)) {
                  _hobbies.add(hobby);
                }
                _hobbyController.clear();
              });
            }
          },
          controller: _hobbyController,
          decoration: InputDecoration(
            labelText: 'Looking for hobbies',
            hintText: 'e.g., Hiking, Cooking',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                final hobby = _hobbyController.text.trim().toLowerCase();
                if (hobby.isNotEmpty) {
                  setState(() {
                    if (!_hobbies.contains(hobby)) {
                      _hobbies.add(hobby);
                    }
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
          children: _hobbies
              .map((hobby) => Chip(
                    label: Text(hobby),
                    onDeleted: () => setState(() => _hobbies.remove(hobby)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildButtonArea(AppLocalizations l) {
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
              child: Text(
                l.common_cancel,
                style: const TextStyle(
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
              child: Text(
                l.discover_applyFilters,
                style: const TextStyle(
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