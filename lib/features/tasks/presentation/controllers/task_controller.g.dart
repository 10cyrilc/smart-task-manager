// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskController)
final taskControllerProvider = TaskControllerProvider._();

final class TaskControllerProvider
    extends $AsyncNotifierProvider<TaskController, TaskState> {
  TaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskControllerHash();

  @$internal
  @override
  TaskController create() => TaskController();
}

String _$taskControllerHash() => r'047960d4e35244599358829e6e3f0e71b491f71f';

abstract class _$TaskController extends $AsyncNotifier<TaskState> {
  FutureOr<TaskState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TaskState>, TaskState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TaskState>, TaskState>,
              AsyncValue<TaskState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
