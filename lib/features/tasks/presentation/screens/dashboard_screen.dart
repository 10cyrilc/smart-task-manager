import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_state.dart';
import '../providers/task_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late final AnimationController _fabAnimController;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(taskControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(taskControllerProvider.notifier).setSearchQuery(query);
    });
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.amber.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);
    final taskStateAsync = ref.watch(taskControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Sync strategy on connection restored
    ref.listen(connectivityProvider, (previous, next) {
      final wasOffline =
          previous?.value?.contains(ConnectivityResult.none) ?? false;
      final isNowOnline =
          next.value != null && !next.value!.contains(ConnectivityResult.none);

      if (wasOffline && isNowOnline) {
        ref.read(offlineSyncServiceProvider).syncPendingOperations().then((_) {
          ref.read(taskControllerProvider.notifier).refresh();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.push('/profile'),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(ref, colorScheme),
                const SizedBox(width: 8),
                _buildSortChip(ref, colorScheme),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline banner with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isOffline
                ? Container(
                    color: colorScheme.error,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 16,
                          color: colorScheme.onError,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You are offline. Showing cached tasks.',
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: taskStateAsync.when(
              data: (state) {
                final tasks = state.filteredAndSortedTasks;

                if (tasks.isEmpty && !state.isLoadingMore) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(taskControllerProvider.notifier).refresh();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                  ),
                                  child: Icon(
                                    Icons.task_alt_rounded,
                                    size: 50,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No tasks found',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enjoy your free time or add a new task!',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(taskControllerProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: tasks.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == tasks.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        index: index,
                        priorityColor: _priorityColor(task.priority),
                        onToggle: (val) {
                          if (val != null) {
                            ref
                                .read(taskControllerProvider.notifier)
                                .updateTask(task.copyWith(isCompleted: val));
                          }
                        },
                        onEdit: () => _showAddTaskDialog(context, ref, task),
                        onDelete: () {
                          ref
                              .read(taskControllerProvider.notifier)
                              .deleteTask(task.id);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.errorContainer,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                        onPressed: () =>
                            ref.read(taskControllerProvider.notifier).refresh(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Task'),
        ),
      ),
    );
  }

  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref, [
    TaskEntity? task,
  ]) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    String priority = task?.priority ?? 'Medium';
    String category = task?.category ?? 'Work';
    DateTime? dueDate = task?.dueDate;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_rounded),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: Text(
                        dueDate == null
                            ? 'Select Due Date'
                            : 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => dueDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: priority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              prefixIcon: Icon(Icons.flag_rounded),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'High',
                                child: Text('High'),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text('Low'),
                              ),
                            ],
                            onChanged: (val) => setState(() => priority = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_rounded),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Work',
                                child: Text('Work'),
                              ),
                              DropdownMenuItem(
                                value: 'Personal',
                                child: Text('Personal'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (val) => setState(() => category = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final newTask = TaskEntity(
                          id: isEditing ? task.id : 0,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          isCompleted: isEditing && task.isCompleted,
                          priority: priority,
                          category: category,
                          userId: isEditing ? task.userId : '',
                          createdAt: isEditing
                              ? task.createdAt
                              : DateTime.now(),
                          dueDate: dueDate,
                        );

                        if (isEditing) {
                          ref
                              .read(taskControllerProvider.notifier)
                              .updateTask(newTask);
                        } else {
                          ref
                              .read(taskControllerProvider.notifier)
                              .addTask(newTask);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Create Task'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(WidgetRef ref, ColorScheme colorScheme) {
    final stateInfo = ref.watch(taskControllerProvider).value;
    final filter = stateInfo?.filter ?? TaskFilter.all;

    return PopupMenuButton<TaskFilter>(
      onSelected: (newFilter) {
        ref.read(taskControllerProvider.notifier).setFilter(newFilter);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              filter.name[0].toUpperCase() + filter.name.substring(1),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => TaskFilter.values.map((f) {
        return PopupMenuItem(
          value: f,
          child: Row(
            children: [
              if (f == filter)
                Icon(Icons.check_rounded, size: 18, color: colorScheme.primary),
              if (f == filter) const SizedBox(width: 8),
              Text(f.name[0].toUpperCase() + f.name.substring(1)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortChip(WidgetRef ref, ColorScheme colorScheme) {
    final stateInfo = ref.watch(taskControllerProvider).value;
    final sort = stateInfo?.sort ?? TaskSort.createdDate;

    return PopupMenuButton<TaskSort>(
      onSelected: (newSort) {
        ref.read(taskControllerProvider.notifier).setSort(newSort);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _sortLabel(sort),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => TaskSort.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Row(
            children: [
              if (s == sort)
                Icon(Icons.check_rounded, size: 18, color: colorScheme.primary),
              if (s == sort) const SizedBox(width: 8),
              Text(_sortLabel(s)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _sortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.dueDate:
        return 'Due Date';
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.createdDate:
        return 'Created';
    }
  }
}

// ─── Task Card Widget ────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.index,
    required this.priorityColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final TaskEntity task;
  final int index;
  final Color priorityColor;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      key: ValueKey(task.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index.clamp(0, 10) * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority indicator bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Checkbox
                Checkbox(
                  value: task.isCompleted,
                  onChanged: onToggle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _Chip(
                              icon: Icons.folder_outlined,
                              label: task.category,
                              color: colorScheme.secondaryContainer,
                              textColor: colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              icon: Icons.flag_rounded,
                              label: task.priority,
                              color: priorityColor.withValues(alpha: 0.15),
                              textColor: priorityColor,
                            ),
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 6),
                              _Chip(
                                icon: Icons.calendar_today_rounded,
                                label:
                                    '${task.dueDate!.day}/${task.dueDate!.month}',
                                color: colorScheme.tertiaryContainer,
                                textColor: colorScheme.onTertiaryContainer,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Actions
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
