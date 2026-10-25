import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/repository/backup_files.dart';

/// share_plus · file_picker · 임시 폴더. 기록·시급이 든 JSON이 tmp/에 남지 않게 다음 내보내기 때 이전 파일을 지운다
/// (공유 시트가 파일을 비동기로 읽을 수 있어 직후 삭제는 위험하다).
class PlatformBackupFiles implements BackupFiles {
  const PlatformBackupFiles();

  @override
  Future<bool> shareJson({required String fileName, required String content}) async {
    final dir = await getTemporaryDirectory();
    await deleteOldBackups(dir);
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
    return const Utf8Decoder(allowMalformed: true).convert(await picked.readAsBytes());
  }
}

final _backupFileName = RegExp(r'^soi_duty_backup_\d{4}-\d{2}-\d{2}\.json$');

/// [dir] 안의 이전 백업 파일(`soi_duty_backup_yyyy-MM-dd.json`)만 지운다.
Future<void> deleteOldBackups(Directory dir) async {
  if (!dir.existsSync()) return;
  await for (final entity in dir.list()) {
    if (entity is File && _backupFileName.hasMatch(entity.uri.pathSegments.last)) {
      try {
        await entity.delete();
      } on FileSystemException {
        // 다른 프로세스가 쥐고 있으면 다음 기회에
      }
    }
  }
}
