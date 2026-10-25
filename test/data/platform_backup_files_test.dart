import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/backup/platform_backup_files.dart';

void main() {
  test('deleteOldBackups — 이전 soi_duty_backup_*.json만 지우고 다른 파일은 둔다', () async {
    final dir = await Directory.systemTemp.createTemp('soi_backup_test');
    addTearDown(() => dir.delete(recursive: true));
    final old1 = File('${dir.path}/soi_duty_backup_2026-10-01.json')..writeAsStringSync('{}');
    final old2 = File('${dir.path}/soi_duty_backup_2026-10-24.json')..writeAsStringSync('{}');
    final other = File('${dir.path}/notes.json')..writeAsStringSync('{}');
    await deleteOldBackups(dir);
    expect(old1.existsSync(), isFalse);
    expect(old2.existsSync(), isFalse);
    expect(other.existsSync(), isTrue);
  });
}
