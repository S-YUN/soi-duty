// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'5aaf17674e5286cd0d73b692ba7f7a5faf2d857d';

@ProviderFor(workRecordRepository)
final workRecordRepositoryProvider = WorkRecordRepositoryProvider._();

final class WorkRecordRepositoryProvider
    extends
        $FunctionalProvider<
          WorkRecordRepository,
          WorkRecordRepository,
          WorkRecordRepository
        >
    with $Provider<WorkRecordRepository> {
  WorkRecordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workRecordRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workRecordRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkRecordRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkRecordRepository create(Ref ref) {
    return workRecordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkRecordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkRecordRepository>(value),
    );
  }
}

String _$workRecordRepositoryHash() =>
    r'483b1112ad8207dca51102f2a2c5a87ee29c8c7b';

@ProviderFor(workRules)
final workRulesProvider = WorkRulesProvider._();

final class WorkRulesProvider
    extends $FunctionalProvider<WorkRules, WorkRules, WorkRules>
    with $Provider<WorkRules> {
  WorkRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workRulesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workRulesHash();

  @$internal
  @override
  $ProviderElement<WorkRules> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkRules create(Ref ref) {
    return workRules(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkRules value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkRules>(value),
    );
  }
}

String _$workRulesHash() => r'c4454602ff600e72bb0d7bf3609a994cbcf56a8a';

@ProviderFor(allRecords)
final allRecordsProvider = AllRecordsProvider._();

final class AllRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkRecord>>,
          List<WorkRecord>,
          Stream<List<WorkRecord>>
        >
    with $FutureModifier<List<WorkRecord>>, $StreamProvider<List<WorkRecord>> {
  AllRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allRecordsHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkRecord>> create(Ref ref) {
    return allRecords(ref);
  }
}

String _$allRecordsHash() => r'e719016168da117dd9f550b50d0ad80a64eed5bb';

@ProviderFor(firstRecordDate)
final firstRecordDateProvider = FirstRecordDateProvider._();

final class FirstRecordDateProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  FirstRecordDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstRecordDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstRecordDateHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return firstRecordDate(ref);
  }
}

String _$firstRecordDateHash() => r'8c2c296cce52ff09c4fe793bcfa8d187e54ecd94';

@ProviderFor(appSettingsRepository)
final appSettingsRepositoryProvider = AppSettingsRepositoryProvider._();

final class AppSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AppSettingsRepository,
          AppSettingsRepository,
          AppSettingsRepository
        >
    with $Provider<AppSettingsRepository> {
  AppSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppSettingsRepository create(Ref ref) {
    return appSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsRepository>(value),
    );
  }
}

String _$appSettingsRepositoryHash() =>
    r'e9b6bfe02a6c0c5663bf85f2f5a76518f88c68fb';

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

final class AppSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'b5ec109e7a7996167b7484d517e9d52acb26bc5a';

@ProviderFor(backupRepository)
final backupRepositoryProvider = BackupRepositoryProvider._();

final class BackupRepositoryProvider
    extends
        $FunctionalProvider<
          BackupRepository,
          BackupRepository,
          BackupRepository
        >
    with $Provider<BackupRepository> {
  BackupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRepositoryHash();

  @$internal
  @override
  $ProviderElement<BackupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupRepository create(Ref ref) {
    return backupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRepository>(value),
    );
  }
}

String _$backupRepositoryHash() => r'da2067c0588407d6b1a80b6683d04713c4630be0';
