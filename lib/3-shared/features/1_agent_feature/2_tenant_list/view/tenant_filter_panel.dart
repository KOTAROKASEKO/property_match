import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Provider をインポート
import '../model/tenant_filter_options.dart';
import '../viewodel/tenant_list_viewmodel.dart'; // ViewModel をインポート

class TenantFilterPanel extends StatefulWidget {
  // ViewModelを受け取る代わりに Provider を使うので initialFilters は不要
  // final TenantFilterOptions initialFilters;
  // final Function(TenantFilterOptions) onApplyFilters; // ViewModel経由で適用

  const TenantFilterPanel({super.key});

  @override
  State<TenantFilterPanel> createState() => _TenantFilterPanelState();
}

class _TenantFilterPanelState extends State<TenantFilterPanel> {
  // State変数はボトムシートと同様
  late RangeValues _budgetRange;
  late String? _roomType;
  late int? _pax;
  late TextEditingController _nationalityController;
  late String? _gender;
  DateTime? _moveinDate;
  final _hobbyController = TextEditingController();
  late List<String> _hobbies;

  // ViewModelへの参照を保持
  late TenantListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // initState 内で ViewModel を取得
    _viewModel = context.read<TenantListViewModel>();
    _initializeFilters(_viewModel.filterOptions);
  }

  // ViewModelのフィルターオプションが変更されたときにUIを更新
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // listen: true で変更を監視
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
    _hobbies = filters.hobbies ?? [];
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
      hobbies: _hobbies.isEmpty ? null : _hobbies,
    );
    // ViewModel のメソッドを呼び出す
    _viewModel.applyFilters(filters);
  }

  void _clearAllFilters() {
    // ViewModel のメソッドを呼び出す
    _viewModel.applyFilters(TenantFilterOptions());
    // UIもリセット (didChangeDependenciesで更新されるが念のため)
    setState(() {
      _budgetRange = const RangeValues(0, 5000);
      _roomType = null;
      _pax = null;
      _nationalityController.clear();
      _gender = null;
      _moveinDate = null;
      _hobbies = [];
      _hobbyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ボトムシートの DraggableScrollableSheet は不要
    //代わりに Container と ListView を使う
    return Container(
      color: Colors.white, // 背景色を設定
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(), // ヘッダー (タイトルとクリアボタン)
          const Divider(height: 24),
          Expanded(
            child: ListView(
              // スクロール可能にする
              children: [
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
                _buildSectionTitle(Icons.tune_outlined, 'Tenant Preferences'),
                _buildDropdown('Room Type', ['Single', 'Middle', 'Master'],
                    _roomType, (val) => setState(() => _roomType = val)),
                const SizedBox(height: 16),
                _buildBudgetSlider(),
                const SizedBox(height: 24),
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
          _buildApplyButton(), // 適用ボタン
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _applyFilters,
        child: const Text('Apply Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- 以下、ボトムシートからコピーしたウィジェット構築ヘルパー ---
  // ( _buildSectionTitle, _buildMoveInDatePicker, _buildPaxDropdown,
  //   _buildGenderDropdown, _buildNationalityInput, _buildHobbiesInput,
  //   _buildBudgetSlider, _buildDropdown はそのままコピー )

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
        child: Text(_moveinDate != null
            ? DateFormat.yMMMd().format(_moveinDate!)
            : 'Any Date'),
      ),
    );
  }

  Widget _buildPaxDropdown() {
    return _buildDropdown(
        'Pax',
        List.generate(10, (index) => (index + 1).toString()),
        _pax?.toString(),
        (val) => setState(() => _pax = val != null ? int.parse(val) : null));
  }

  Widget _buildGenderDropdown() {
    return _buildDropdown('Gender', ['Male', 'Female', 'Mix'], _gender,
        (val) => setState(() => _gender = val));
  }

  Widget _buildNationalityInput() {
    return TextFormField(
      controller: _nationalityController,
      decoration: const InputDecoration(
        labelText: 'Nationality',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        // ViewModel に即時反映はしない（Applyボタンで反映）
      },
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
                    // 重複をチェック
                    if (!_hobbies.contains(_hobbyController.text.trim())) {
                      _hobbies.add(_hobbyController.text.trim());
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
            'RM ${_budgetRange.end.round() == 5000 ? "5000+" : _budgetRange.end.round()}',
          ),
          onChanged: (values) => setState(() => _budgetRange = values),
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.deepPurple.withOpacity(0.2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RM ${_budgetRange.start.round()}'),
            Text(_budgetRange.end.round() == 5000
                ? "RM 5000+"
                : 'RM ${_budgetRange.end.round()}'),
          ],
        )
      ],
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