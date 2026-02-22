import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_client.dart';

part 'global_providers.g.dart';

@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) {
  return DioClient();
}