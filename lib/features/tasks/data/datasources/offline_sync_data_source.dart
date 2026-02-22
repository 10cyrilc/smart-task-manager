import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pending_operation.dart';

class OfflineSyncDataSource {
  static const String _boxName = 'pending_ops_box';
  static const String _opsKey = 'pending_ops';

  Future<void> addOperation(PendingOperation operation) async {
    final box = await Hive.openBox(_boxName);
    final String? existingJson = box.get(_opsKey);
    final List<dynamic> list = existingJson != null
        ? jsonDecode(existingJson)
        : [];

    // Convert to maps
    list.add(operation.toJson());

    await box.put(_opsKey, jsonEncode(list));
  }

  Future<List<PendingOperation>> getPendingOperations() async {
    final box = await Hive.openBox(_boxName);
    final String? existingJson = box.get(_opsKey);
    if (existingJson == null) return [];

    final List<dynamic> list = jsonDecode(existingJson);
    return list.map((json) => PendingOperation.fromJson(json)).toList();
  }

  Future<void> clearOperations() async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_opsKey);
  }
}
