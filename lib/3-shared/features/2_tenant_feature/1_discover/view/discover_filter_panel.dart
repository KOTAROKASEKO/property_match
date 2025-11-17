// lib/features/2_tenant_feature/1_discover/view/discover_filter_panel.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_list_screen.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_screen.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import '../model/filter_options.dart';
import '../viewmodel/discover_viewmodel.dart';
// ★★★ インポート追加 (1/2) ★★★
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'your_ai_chat_screen.dart'; // ★ AIチャット画面をインポート

class DiscoverFilterPanel extends StatefulWidget {
  const DiscoverFilterPanel({super.key});

  @override
  State<DiscoverFilterPanel> createState() => _DiscoverFilterPanelState();
}

class _DiscoverFilterPanelState extends State<DiscoverFilterPanel> {
  // ... (initStateや他の変数は変更なし) ...
  late String? _gender;
  late List<String> _selectedRoomTypes;
  late TextEditingController _semanticQueryController;
  RangeValues _rentRange = const RangeValues(0, 5000);
  DateTime? _durationStart;
  int? _durationMonth;

  final List<String> _genderOptions = ['Male', 'Female', 'Mix', 'Any'];
  final List<String> _roomTypeOptions = ['Single', 'Middle', 'Master'];

  late DiscoverViewModel _viewModel; // ViewModel reference

  final _hobbyController = TextEditingController();
  late List<String> _hobbies;

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
      gender: _gender == 'Any' ? null : _gender, // Send null if 'Any'
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

  // ... (buildメソッドは変更なし) ...
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
            // ★★★ 変更点: ListView の子を _buildSectionCard に変更 ★★★
            child: ListView(
              children: [
                _buildSectionCard(
                  icon: Icons.auto_awesome, // ★ アイコン
                  title: 'AI Search Assistant', // ★ タイトル
                  children: [
                    _buildAIChatButton(context), // ★ AIチャットボタン
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.calendar_today_outlined, // ★ アイコン
                  title: 'Availability', // ★ タイトル
                  children: [
                    _buildDateRangePicker(context),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.home_outlined, // ★ アイコン
                  title: 'Property Details', // ★ タイトル
                  children: [
                    const Text("Gender",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildGenderChips(),
                    const SizedBox(height: 16),
                    const Text("Room Type",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildRoomTypeToggle(),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.attach_money_outlined, // ★ アイコン
                  title: 'Rent Range (RM)', // ★ タイトル
                  children: [
                    _buildRentSlider(),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.lightbulb_outline, // ★ アイコン
                  title: 'Atmosphere / Keywords', // ★ タイトル
                  children: [
                    _buildSemanticQueryInput(),
                  ],
                ),
                _buildSectionCard(
                  icon: Icons.pool_outlined, // ★ アイコン
                  title: 'Hobbies & Lifestyle', // ★ タイトル
                  children: [
                    _buildHobbiesInput(),
                  ],
                ),
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

  // ★★★ 修正 (2/4): _buildAIChatButton の onPressed を async に変更 ★★★
  Widget _buildAIChatButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.chat_outlined, size: 18),
      label: const Text('Chat with AI to Find Your Room'),
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
        // ★★★ 修正 (3/4): 認証チェックとチャットID取得/作成ロジックを「削除」 ★★★
        if(userData.userId.isNotEmpty){
          
          if (!context.mounted) return;
          // ★★★ 修正 (4/4): AIChatListScreen に遷移 ★★★
          final aiFilters = await Navigator.push<FilterOptions>(
            context,
            // ★ AIChatScreen ではなく AIChatListScreen を呼び出す
            MaterialPageRoute(builder: (_) => const AIChatListScreen()),
          );

          if (aiFilters != null) {
            _viewModel.applyFilters(aiFilters);
          }
        } else {
          showSignInModal(context);
        }
      },
    );
  }

  // ... (他の _build... ヘルパーは変更なし) ...
  // ★★★ 新しいヘルパーウィジェット: セクションカード ★★★
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
            // アイコンとタイトル
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
            // 子ウィジェット
            ...children,
          ],
        ),
      ),
    );
  }

  // --- 既存のヘルパーウィジェット (変更なし) ---
  // ( _buildHobbiesInput, _buildDateRangePicker, _buildGenderChips,
  //   _buildRoomTypeToggle, _getBorderRadius, _buildRentSlider,
  //   _buildSemanticQueryInput )

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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            initialValue: _durationMonth?.toString(), // ★ 修正: initialValue を設定
            decoration: InputDecoration(
              labelText: 'Duration (Months)', // Simplified label
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            Text(_rentRange.end.round() == 5000
                ? "RM 5000+"
                : 'RM ${_rentRange.end.round()}'),
          ],
        )
      ],
    );
  }

  Widget _buildSemanticQueryInput() {
    // This UI works well in a panel
    return TextFormField(
      controller: _semanticQueryController, // ★ 変更
      decoration: InputDecoration(
        hintText: 'e.g., "sunny", "stylish furniture"', // ★ 変更
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
        prefixIcon:
            Icon(Icons.auto_awesome_outlined, color: Colors.grey[500]), // ★ 変更
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) {
        // No immediate action needed, applied via button
      },
    );
  }
}