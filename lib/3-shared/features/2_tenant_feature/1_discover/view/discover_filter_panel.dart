import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/discover_viewmodel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_layout.dart';
import 'package:re_conver/l10n/app_localizations.dart';

class DiscoverFilterPanel extends StatefulWidget {
  const DiscoverFilterPanel({super.key});

  @override
  State<DiscoverFilterPanel> createState() => _DiscoverFilterPanelState();
}

class _DiscoverFilterPanelState extends State<DiscoverFilterPanel> {
  late String? _gender;
  late List<String> _selectedRoomTypes;
  late TextEditingController _semanticQueryController;
  RangeValues _rentRange = const RangeValues(0, 5000);
  DateTime? _durationStart;
  int? _durationMonth;

  final List<String> _genderOptions = ['Male', 'Female', 'Mix', 'Any'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  late DiscoverViewModel _viewModel;

  final _hobbyController = TextEditingController();
  late List<String> _hobbies;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<DiscoverViewModel>();
    _initializeFilters(_viewModel.filterOptions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentFilters = context.watch<DiscoverViewModel>().filterOptions;
    _initializeFilters(currentFilters);
  }

  void _initializeFilters(FilterOptions filters) {
    _gender = filters.gender ?? 'Any';
    _selectedRoomTypes = filters.roomType ?? [];
    _semanticQueryController =
        TextEditingController(text: filters.semanticQuery);
    _rentRange = RangeValues(
      filters.minRent ?? 0,
      filters.maxRent ?? 5000,
    );
    _durationStart = filters.durationStart;
    _durationMonth = filters.durationMonth;
    _hobbies = filters.hobbies ?? [];
  }

  void _applyFilters() {
    final filters = FilterOptions(
      gender: _gender == 'Any' ? null : _gender,
      roomType: _selectedRoomTypes.isEmpty ? null : _selectedRoomTypes,
      semanticQuery: _semanticQueryController.text.trim().isEmpty
          ? null
          : _semanticQueryController.text.trim(),
      minRent: _rentRange.start == 0 ? null : _rentRange.start,
      maxRent: _rentRange.end == 5000 ? null : _rentRange.end,
      durationStart: _durationStart,
      durationMonth: _durationMonth,
      hobbies: _hobbies.isEmpty ? null : _hobbies,
    );
    _viewModel.applyFilters(filters);
  }

  void _clearAllFilters() {
    _viewModel.applyFilters(FilterOptions());
    setState(() {
      _gender = 'Any';
      _selectedRoomTypes = [];
      _semanticQueryController.clear();
      _rentRange = const RangeValues(0, 5000);
      _durationStart = null;
      _durationMonth = null;
      _hobbies = [];
      _hobbyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(l),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildSectionCard(
                  color: Colors.amber,
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
                    _buildRentSlider(l),
                  ],
                ),
              ],
            ),
          ),
          _buildApplyButton(l),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l.discover_filtersTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: _clearAllFilters,
          child: Text(l.discover_clearAll),
        ),
      ],
    );
  }

  Widget _buildApplyButton(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _applyFilters,
        child: Text(l.discover_applyFilters,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAIChatButton(BuildContext context, AppLocalizations l) {
    return ElevatedButton.icon(
      icon: const Padding(
        padding: EdgeInsetsGeometry.only(left: 10),
        child: Icon(Icons.rocket_launch, size: 18),
      ),
      label: Text('${l.discover_tryMe}  '),
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
        if (!context.mounted) return;

        final aiFilters = await Navigator.push<FilterOptions>(
          context,
          MaterialPageRoute(builder: (_) => const AIChatMainLayout()),
        );
        if (aiFilters != null) {
          _viewModel.applyFilters(aiFilters);
        }
      },
    );
  }

  Widget _buildSectionCard({
    Color? color,
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
                Icon(icon, color: color ?? Colors.deepPurple, size: 20),
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
          child: TextFormField(
            initialValue: _durationMonth?.toString(),
            decoration: InputDecoration(
              labelText: l.discover_durationMonths,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              suffixText: l.deposit_mths,
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
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!)),
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
    const radius = Radius.circular(15);
    if (index == 0) {
      return const BorderRadius.horizontal(left: radius);
    } else if (index == _roomTypeOptions.length - 1) {
      return const BorderRadius.horizontal(right: radius);
    }
    return BorderRadius.zero;
  }

  Widget _buildRentSlider(AppLocalizations l) {
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
            Text(_rentRange.end.round() == 5000
                ? "RM 5000+"
                : 'RM ${_rentRange.end.round()}'),
          ],
        )
      ],
    );
  }
}