import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'backup_files.g.dart';

/// 백업 파일을 밖으로 내보내고(OS 공유 시트) 안으로 들여오는(OS 파일 선택) 길. 테스트는 Fake로 바꾼다.
abstract interface class BackupFiles {
  /// 임시 파일을 만들어 공유 시트를 연다. 사용자가 그냥 닫았으면(dismissed) false.
  Future<bool> shareJson({required String fileName, required String content});

  /// 파일 선택 화면. 취소하면 null.
  Future<String?> pickJson();
}

class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  @override
  Future<bool> shareJson({required String fileName, required String content}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json', name: fileName)]),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  @override
  Future<String?> pickJson() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return const Utf8Decoder(allowMalformed: true).convert(bytes);
  }
}

@Riverpod(keepAlive: true)
BackupFiles backupFiles(Ref ref) => const PlatformBackupFiles();
