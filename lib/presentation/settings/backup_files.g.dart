// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_files.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupFiles)
final backupFilesProvider = BackupFilesProvider._();

final class BackupFilesProvider
    extends $FunctionalProvider<BackupFiles, BackupFiles, BackupFiles>
    with $Provider<BackupFiles> {
  BackupFilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupFilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupFilesHash();

  @$internal
  @override
  $ProviderElement<BackupFiles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupFiles create(Ref ref) {
    return backupFiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupFiles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupFiles>(value),
    );
  }
}

String _$backupFilesHash() => r'd809b112ec6e8edd1560729d0809b4b767e6d563';
