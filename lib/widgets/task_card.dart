import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/add_edit_task_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFF44336),
    ];
    final priorityColor = priorityColors[task.priority.index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: Key(task.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => context.read<TaskProvider>().toggleTask(task.id),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              icon: task.isCompleted
                  ? Icons.refresh_rounded
                  : Icons.check_rounded,
              label: task.isCompleted ? 'Undo' : 'Done',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(task: task)),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => _deleteTask(context),
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isOverdue
                    ? const Color(0xFFF44336).withValues(alpha: 0.4)
                    : colorScheme.outline.withValues(alpha: 0.1),
                width: task.isOverdue ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority bar
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          task.isCompleted ? colorScheme.outline.withValues(alpha: 0.3) : priorityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Checkbox
                  GestureDetector(
                    onTap: () =>
                        context.read<TaskProvider>().toggleTask(task.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? priorityColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? priorityColor
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? Icon(Icons.check_rounded,
                              size: 14, color: priorityColor)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted
                                        ? colorScheme.onSurface.withValues(alpha: 0.4)
                                        : colorScheme.onSurface,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Tags row
                        Row(
                          children: [
                            _Tag(
                              label: '${task.category.emoji} ${task.category.label}',
                              color: colorScheme.secondaryContainer,
                              textColor: colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 6),
                            if (task.dueDate != null)
                              _Tag(
                                label: _formatDue(task),
                                color: task.isOverdue
                                    ? const Color(0xFFF44336).withValues(alpha: 0.15)
                                    : task.isDueToday
                                        ? const Color(0xFFFFC107).withValues(alpha: 0.2)
                                        : colorScheme.surfaceContainerHighest,
                                textColor: task.isOverdue
                                    ? const Color(0xFFF44336)
                                    : task.isDueToday
                                        ? const Color(0xFFE65100)
                                        : colorScheme.onSurfaceVariant,
                                icon: task.hasReminder
                                    ? Icons.notifications_active_rounded
                                    : Icons.calendar_today_rounded,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDue(Task task) {
    final date = task.dueDate!;
    if (task.isOverdue) {
      return 'Overdue';
    } else if (task.isDueToday) {
      return 'Today ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

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
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
        ],
      ),
    );
  }
}
