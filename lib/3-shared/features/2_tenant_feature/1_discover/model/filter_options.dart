// lib/features/2_tenant_feature/1_discover/model/filter_options.dart

class FilterOptions {
  final String? gender;
  final List<String>? roomType; // Changed from String?
  // final String? condoName; // ★★★ 1. 削除 ★★★
  final double? minRent;
  final double? maxRent;
  final DateTime? durationStart;
  final int? durationMonth;
  final List<String>? hobbies;
  final String? semanticQuery; // ★★★ 2. AI検索クエリ用のフィールドを追加 ★★★

  FilterOptions({
    this.gender,
    this.roomType,
    // this.condoName, // ★★★ 3. 削除 ★★★
    this.minRent,
    this.maxRent,
    this.durationStart,
    this.durationMonth,
    this.hobbies,
    this.semanticQuery, // ★★★ 4. 追加 ★★★
  });

  // Check if any filters are applied
  bool get isClear =>
      gender == null &&
      (roomType == null || roomType!.isEmpty) && // Updated for List
      // (condoName == null || condoName!.isEmpty) && // ★★★ 5. 削除 ★★★
      minRent == null &&
      maxRent == null &&
      durationStart == null &&
      durationMonth == null &&
      (hobbies == null || hobbies!.isEmpty) &&
      (semanticQuery == null || semanticQuery!.isEmpty); // ★★★ 6. 追加 ★★★
}