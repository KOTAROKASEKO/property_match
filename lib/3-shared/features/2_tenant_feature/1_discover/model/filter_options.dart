// lib/features/2_tenant_feature/1_discover/model/filter_options.dart

class FilterOptions {
  final String? gender;
  final List<String>? roomType; // Changed from String?
  final String? condoName;
  final double? minRent;
  final double? maxRent;
  final DateTime? durationStart;
  final DateTime? durationEnd;

  FilterOptions({
    this.gender,
    this.roomType,
    this.condoName,
    this.minRent,
    this.maxRent,
    this.durationStart,
    this.durationEnd,
  });

  // Check if any filters are applied
  bool get isClear =>
      gender == null &&
      (roomType == null || roomType!.isEmpty) && // Updated for List
      (condoName == null || condoName!.isEmpty) &&
      minRent == null &&
      maxRent == null &&
      durationStart == null &&
      durationEnd == null;
}