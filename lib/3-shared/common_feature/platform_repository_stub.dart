// lib/3-shared/common_feature/platform_repository_stub.dart
// (新しくこのファイルを作成します)

/// モバイル (Isar) の実装をデフォルトでエクスポート
export 'package:chatrepo_isar/src/repository_provider_mobile.dart' 
    
    /// Web (dart.library.html) の場合は、Drift の実装をエクスポート
    if (dart.library.html) 'package:chatrepo_drift/src/connection/repository_provider_web.dart';