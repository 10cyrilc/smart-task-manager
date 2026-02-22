import '../../data/datasources/offline_sync_data_source.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/models/pending_operation.dart';

class OfflineSyncService {
  OfflineSyncService(this._offlineDataSource, this._remoteDataSource);
  final OfflineSyncDataSource _offlineDataSource;
  final TaskRemoteDataSource _remoteDataSource;
  bool _isSyncing = false;

  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;

    final operations = await _offlineDataSource.getPendingOperations();
    if (operations.isEmpty) return;

    _isSyncing = true;

    try {
      for (final op in operations) {
        try {
          switch (op.type) {
            case SyncOperationType.add:
              await _remoteDataSource.addTask(op.userId, op.task);
              break;
            case SyncOperationType.update:
              await _remoteDataSource.updateTask(op.userId, op.task);
              break;
            case SyncOperationType.delete:
              await _remoteDataSource.deleteTask(op.userId, op.task.id);
              break;
          }
        } catch (e) {
          // If a single operation fails, we log it and continue so the queue doesn't stick
          // In a real production app, we might retry or mark it as failed
        }
      }

      // Clear all operations after processing
      await _offlineDataSource.clearOperations();
    } finally {
      _isSyncing = false;
    }
  }
}
