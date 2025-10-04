// lib/2_tenant_feature/2_discover/model/filter_options.dart

class FilterOptions {
  final String? gender;
  final String? roomType;
  final String? condoName;
  final double? minRent;
  final double? maxRent;

  FilterOptions({
    this.gender,
    this.roomType,
    this.condoName,
    this.minRent,
    this.maxRent,
  });

  // フィルターが適用されているかどうかを判定する
  bool get isClear =>
      gender == null &&
      roomType == null &&
      (condoName == null || condoName!.isEmpty) &&
      minRent == null &&
      maxRent == null;
}