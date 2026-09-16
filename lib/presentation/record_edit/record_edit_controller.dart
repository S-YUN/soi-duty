import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import 'record_draft.dart';

part 'record_edit_controller.g.dart';

/// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.
@riverpod
class RecordEditController extends _$RecordEditController {
  @override
  void build() {}

  Future<void> save(RecordDraft draft) {
    final repo = ref.read(workRecordRepositoryProvider);
    return draft.isEmptyNormal ? repo.delete(draft.date) : repo.save(draft.toRecord());
  }

  Future<void> delete(DateTime date) => ref.read(workRecordRepositoryProvider).delete(date);
}
