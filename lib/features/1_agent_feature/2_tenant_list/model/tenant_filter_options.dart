class TenantFilterOptions {
  final double? minBudget;
  final double? maxBudget;
  final String? roomType;
  final int? pax;
  final String? location;
  final String? nationality; // ★ 追加
  final String? gender;      // ★ 追加

  TenantFilterOptions({
    this.minBudget,
    this.maxBudget,
    this.roomType,
    this.pax,
    this.location,
    this.nationality, // ★ 追加
    this.gender,      // ★ 追加
  });

  bool get isClear =>
      (minBudget == null || minBudget == 0) &&
      (maxBudget == null || maxBudget == 5000) &&
      roomType == null &&
      pax == null &&
      (location == null || location!.isEmpty) &&
      (nationality == null || nationality!.isEmpty) && // ★ 追加
      gender == null; // ★ 追加
}