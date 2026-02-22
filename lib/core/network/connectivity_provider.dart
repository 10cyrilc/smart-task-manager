import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivity(Ref ref) {
  return Connectivity().onConnectivityChanged;
}

@riverpod
bool isOffline(Ref ref) {
  final connectivityState = ref.watch(connectivityProvider);

  return connectivityState.when(
    data: (results) => results.contains(ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
}
