class TenantFilterOptions {
  final double? minBudget;
  final double? maxBudget;
  final String? roomType;
  final int? pax;

  TenantFilterOptions({
    this.minBudget,
    this.maxBudget,
    this.roomType,
    this.pax,
  });

  bool get isClear =>
      minBudget == 0 &&
      maxBudget == 5000 &&
      roomType == null &&
      pax == null;
}
