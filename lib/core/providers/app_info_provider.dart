import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_provider.g.dart';

/// 설정 "앱 정보"의 버전 문자열 (예: 1.0.1). 빌드 번호는 보이지 않는다.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async => (await PackageInfo.fromPlatform()).version;
