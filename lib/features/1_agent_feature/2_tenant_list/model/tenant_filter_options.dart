// lib/features/1_agent_feature/2_tenant_list/model/tenant_filter_options.dart
class TenantFilterOptions {
  final double? minBudget;
  final double? maxBudget;
  final String? roomType;
  final int? pax;
  final String? location;
  final String? nationality;
  final String? gender;
  final DateTime? moveinDate;
  final List<String>? hobbies; // Added hobbies

  TenantFilterOptions({
    this.minBudget,
    this.maxBudget,
    this.roomType,
    this.pax,
    this.location,
    this.nationality,
    this.gender,
    this.moveinDate,
    this.hobbies, // Added hobbies
  });

  bool get isClear =>
      (minBudget == null || minBudget == 0) &&
      (maxBudget == null || maxBudget == 5000) &&
      roomType == null &&
      pax == null &&
      (location == null || location!.isEmpty) &&
      (nationality == null || nationality!.isEmpty) &&
      moveinDate == null &&
      gender == null &&
      (hobbies == null || hobbies!.isEmpty); // Added hobbies
}