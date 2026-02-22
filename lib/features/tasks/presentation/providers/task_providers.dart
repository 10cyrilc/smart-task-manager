import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/global_providers.dart';
import '../../data/datasources/offline_sync_data_source.dart';
import '../../data/datasources/task_local_data_source.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/services/offline_sync_service.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
TaskLocalDataSource taskLocalDataSource(Ref ref) {
  return TaskLocalDataSourceImpl();
}

@Riverpod(keepAlive: true)
OfflineSyncDataSource offlineSyncDataSource(Ref ref) {
  return OfflineSyncDataSource();
}

@Riverpod(keepAlive: true)
TaskRemoteDataSource taskRemoteDataSource(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TaskRemoteDataSourceImpl(dioClient);
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  final localDataSource = ref.watch(taskLocalDataSourceProvider);
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  final offlineSyncSource = ref.watch(offlineSyncDataSourceProvider);
  final connectivity = Connectivity();

  return TaskRepositoryImpl(remoteDataSource, localDataSource, offlineSyncSource, connectivity);
}

@Riverpod(keepAlive: true)
OfflineSyncService offlineSyncService(Ref ref) {
  final offlineSyncSource = ref.watch(offlineSyncDataSourceProvider);
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  return OfflineSyncService(offlineSyncSource, remoteDataSource);
}
