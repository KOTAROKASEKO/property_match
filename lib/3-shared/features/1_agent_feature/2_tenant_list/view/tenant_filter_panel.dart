import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/l10n/app_localizations.dart'; // ★ 追加
import '../model/tenant_filter_options.dart';
import '../viewodel/tenant_list_viewmodel.dart';

class TenantFilterPanel extends StatefulWidget {
  const TenantFilterPanel({super.key});

  @override
  State<TenantFilterPanel> createState() => _TenantFilterPanelState();
}

class _TenantFilterPanelState extends State<TenantFilterPanel> {
  late RangeValues _budgetRange;
  late String? _roomType;
  late int? _pax;
  late TextEditingController _nationalityController;
  late String? _gender;
  DateTime? _moveinDate;

  // チップ選択用のオプション定義 (内部ロジック用)
  final List<String> _genderOptions = ['Male', 'Female', 'Mix'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  late TenantListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<TenantListViewModel>();
    _initializeFilters(_viewModel.filterOptions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentFilters = context.watch<TenantListViewModel>().filterOptions;
    _initializeFilters(currentFilters);
  }

  void _initializeFilters(TenantFilterOptions filters) {
    _budgetRange = RangeValues(
      filters.minBudget ?? 0,
      filters.maxBudget ?? 5000,
    );
    _roomType = filters.roomType;
    _pax = filters.pax;
    _nationalityController = TextEditingController(text: filters.nationality);
    _gender = filters.gender;
    _moveinDate = filters.moveinDate;
  }

  void _applyFilters() {
    final filters = TenantFilterOptions(
      minBudget: _budgetRange.start > 0 ? _budgetRange.start : null,
      maxBudget: _budgetRange.end < 5000 ? _budgetRange.end : null,
      roomType: _roomType,
      pax: _pax,
      nationality: _nationalityController.text.trim().isEmpty
          ? null
          : _nationalityController.text.trim(),
      gender: _gender,
      moveinDate: _moveinDate,
      // hobbies は削除済み
    );
    _viewModel.applyFilters(filters);
  }

  void _clearAllFilters() {
    _viewModel.applyFilters(TenantFilterOptions());
    setState(() {
      _budgetRange = const RangeValues(0, 5000);
      _roomType = null;
      _pax = null;
      _nationalityController.clear();
      _gender = null;
      _moveinDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // ★ Localization取得

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
                  icon: Icons.article_outlined,
                  title: l.tenantFilter_tenancyDetails, // ★ 翻訳
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMoveInDatePicker(l)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPaxDropdown(l)),
                      ],
                    ),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.tune_outlined,
                  title: l.tenantFilter_tenantPreferences, // ★ 翻訳
                  children: [
                    Text(l.tenantFilter_roomType, style: const TextStyle(fontWeight: FontWeight.w500)), // ★ 翻訳
                    const SizedBox(height: 8),
                    _buildRoomTypeChips(l), // モダンなチップ選択に変更
                    const SizedBox(height: 24),
                    Text(l.tenantFilter_budgetRange, style: const TextStyle(fontWeight: FontWeight.w500)), // ★ 翻訳
                    _buildBudgetSlider(l),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.person_outline,
                  title: l.tenantFilter_tenantProfile, // ★ 翻訳
                  children: [
                    Text(l.tenantFilter_gender, style: const TextStyle(fontWeight: FontWeight.w500)), // ★ 翻訳
                    const SizedBox(height: 8),
                    _buildGenderChips(l), // モダンなチップ選択に変更
                    const SizedBox(height: 16),
                    _buildNationalityInput(l),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          _buildApplyButton(l),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader(AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l.tenantFilter_title, // ★ 翻訳
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: _clearAllFilters,
          child: Text(l.tenantFilter_clearAll), // ★ 翻訳
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
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _applyFilters,
        child: Text(l.tenantFilter_applyFilters, // ★ 翻訳
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // モダンなカードデザインのコンテナ
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.grey[50], // 薄いグレーの背景
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

  // Room Type Chips
  Widget _buildRoomTypeChips(AppLocalizations l) {
    return Wrap(
      spacing: 8.0,
      children: _roomTypeOptions.map((type) {
        final isSelected = _roomType == type;
        
        // ★ 表示名の変換
        String label = type;
        if(type == 'Single') label = l.tenantFilter_roomSingle;
        if(type == 'Middle') label = l.tenantFilter_roomMiddle;
        if(type == 'Master') label = l.tenantFilter_roomMaster;

        return ChoiceChip(
          label: Text(label),
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

  // Gender Chips
  Widget _buildGenderChips(AppLocalizations l) {
    return Wrap(
      spacing: 8.0,
      children: _genderOptions.map((gender) {
        final isSelected = _gender == gender;

        // ★ 表示名の変換
        String label = gender;
        if(gender == 'Male') label = l.tenantFilter_genderMale;
        if(gender == 'Female') label = l.tenantFilter_genderFemale;
        if(gender == 'Mix') label = l.tenantFilter_genderMix;

        return ChoiceChip(
          label: Text(label),
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

  Widget _buildMoveInDatePicker(AppLocalizations l) {
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
          labelText: l.tenantFilter_moveInDate, // ★ 翻訳
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _moveinDate != null ? DateFormat.yMMMd().format(_moveinDate!) : l.tenantFilter_anyDate, // ★ 翻訳
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPaxDropdown(AppLocalizations l) {
    return DropdownButtonFormField<String>(
      value: _pax?.toString(),
      decoration: InputDecoration(
        labelText: l.tenantFilter_pax, // ★ 翻訳
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

  Widget _buildNationalityInput(AppLocalizations l) {
    return TextFormField(
      controller: _nationalityController,
      decoration: InputDecoration(
        labelText: l.tenantFilter_nationality, // ★ 翻訳
        hintText: l.tenantFilter_nationalityHint, // ★ 翻訳
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildBudgetSlider(AppLocalizations l) {
    return Column(
      children: [
        RangeSlider(
          values: _budgetRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            'RM ${_budgetRange.start.round()}',
            'RM ${_budgetRange.end.round() == 5000 ? "5000+" : _budgetRange.end.round()}',
          ),
          onChanged: (values) => setState(() => _budgetRange = values),
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.deepPurple.withOpacity(0.2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RM ${_budgetRange.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_budgetRange.end.round() == 5000
                ? l.tenantFilter_budget5000Plus // ★ 翻訳
                : 'RM ${_budgetRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}