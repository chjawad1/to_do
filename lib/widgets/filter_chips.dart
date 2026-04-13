import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class FilterChipsWidget extends StatelessWidget {
  const FilterChipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // All
          _FilterChip(
            label: 'All',
            emoji: '📋',
            isSelected:
                provider.selectedCategory == null && provider.selectedPriority == null,
            onTap: () {
              provider.setCategory(null);
              provider.setPriority(null);
            },
          ),
          const SizedBox(width: 8),

          // Today
          _FilterChip(
            label: 'Today',
            emoji: '📅',
            isSelected: false,
            onTap: () {},
          ),
          const SizedBox(width: 8),

          // Priority filters
          ...Priority.values.map((p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: p.label,
                  emoji: p.emoji,
                  isSelected: provider.selectedPriority == p,
                  onTap: () => provider.setPriority(
                    provider.selectedPriority == p ? null : p,
                  ),
                ),
              )),

          // Category filters
          ...Category.values.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: c.label,
                  emoji: c.emoji,
                  isSelected: provider.selectedCategory == c,
                  onTap: () => provider.setCategory(
                    provider.selectedCategory == c ? null : c,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
