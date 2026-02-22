// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskLocalDataSource)
final taskLocalDataSourceProvider = TaskLocalDataSourceProvider._();

final class TaskLocalDataSourceProvider
    extends
        $FunctionalProvider<
          TaskLocalDataSource,
          TaskLocalDataSource,
          TaskLocalDataSource
        >
    with $Provider<TaskLocalDataSource> {
  TaskLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<TaskLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskLocalDataSource create(Ref ref) {
    return taskLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskLocalDataSource>(value),
    );
  }
}

String _$taskLocalDataSourceHash() =>
    r'1fb9eb2ad88458cfe886b425af4cbe9ca58abf74';

@ProviderFor(offlineSyncDataSource)
final offlineSyncDataSourceProvider = OfflineSyncDataSourceProvider._();

final class OfflineSyncDataSourceProvider
    extends
        $FunctionalProvider<
          OfflineSyncDataSource,
          OfflineSyncDataSource,
          OfflineSyncDataSource
        >
    with $Provider<OfflineSyncDataSource> {
  OfflineSyncDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineSyncDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineSyncDataSourceHash();

  @$internal
  @override
  $ProviderElement<OfflineSyncDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OfflineSyncDataSource create(Ref ref) {
    return offlineSyncDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineSyncDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineSyncDataSource>(value),
    );
  }
}

String _$offlineSyncDataSourceHash() =>
    r'78507af95c62d4326438148a9754a377ae0e4421';

@ProviderFor(taskRemoteDataSource)
final taskRemoteDataSourceProvider = TaskRemoteDataSourceProvider._();

final class TaskRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TaskRemoteDataSource,
          TaskRemoteDataSource,
          TaskRemoteDataSource
        >
    with $Provider<TaskRemoteDataSource> {
  TaskRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TaskRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TaskRemoteDataSource create(Ref ref) {
    return taskRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRemoteDataSource>(value),
    );
  }
}

String _$taskRemoteDataSourceHash() =>
    r'55051d4592c14d735f7e421f7ed295e6cfc6d690';

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'af86714dbce8b165355b58d822e6e5f3b3f732d6';

@ProviderFor(offlineSyncService)
final offlineSyncServiceProvider = OfflineSyncServiceProvider._();

final class OfflineSyncServiceProvider
    extends
        $FunctionalProvider<
          OfflineSyncService,
          OfflineSyncService,
          OfflineSyncService
        >
    with $Provider<OfflineSyncService> {
  OfflineSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineSyncServiceHash();

  @$internal
  @override
  $ProviderElement<OfflineSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OfflineSyncService create(Ref ref) {
    return offlineSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineSyncService>(value),
    );
  }
}

String _$offlineSyncServiceHash() =>
    r'284927f1d4ddeb5608670565eb8db79dc0e438e8';
