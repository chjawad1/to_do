import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final total = provider.totalTasks;
    final completed = provider.completedTasks;
    final pending = provider.pendingTasks;
    final overdue = provider.overdueTasks;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Total',
                  value: total.toString(),
                  icon: Icons.list_alt_rounded,
                ),
                _StatItem(
                  label: 'Done',
                  value: completed.toString(),
                  icon: Icons.check_circle_rounded,
                ),
                _StatItem(
                  label: 'Pending',
                  value: pending.toString(),
                  icon: Icons.pending_rounded,
                ),
                _StatItem(
                  label: 'Overdue',
                  value: overdue.toString(),
                  icon: Icons.warning_rounded,
                  isWarning: overdue > 0,
                ),
              ],
            ),
            if (total > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            color: isWarning
                ? const Color(0xFFFFEB3B)
                : Colors.white.withOpacity(0.8),
            size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              color: isWarning ? const Color(0xFFFFEB3B) : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            )),
        Text(label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
