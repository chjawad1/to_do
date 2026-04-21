import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Priority _priority = Priority.medium;
  Category _category = Category.personal;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _hasReminder = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _priority = t.priority;
      _category = t.category;
      _dueDate = t.dueDate;
      _hasReminder = t.hasReminder;
      if (t.dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(t.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FilledButton(
            onPressed: _saveTask,
            child: Text(_isEditing ? 'Update' : 'Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              autofocus: !_isEditing,
              decoration: InputDecoration(
                labelText: 'Task Title *',
                hintText: 'What needs to be done?',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add notes...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Priority
            const _SectionLabel(label: 'Priority', icon: Icons.flag_rounded),
            const SizedBox(height: 10),
            Row(
              children: Priority.values
                  .map((p) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PriorityChip(
                            priority: p,
                            isSelected: _priority == p,
                            onTap: () => setState(() => _priority = p),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Category
            const _SectionLabel(label: 'Category', icon: Icons.category_rounded),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Category.values
                  .map((c) => _CategoryChip(
                        category: c,
                        isSelected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Due Date
            const _SectionLabel(label: 'Due Date & Time', icon: Icons.calendar_today_rounded),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PickerCard(
                    icon: Icons.calendar_month_rounded,
                    label: _dueDate == null
                        ? 'Pick Date'
                        : DateFormat('EEE, MMM d').format(_dueDate!),
                    hasValue: _dueDate != null,
                    onTap: _pickDate,
                    onClear: _dueDate != null
                        ? () => setState(() {
                              _dueDate = null;
                              _dueTime = null;
                              _hasReminder = false;
                            })
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerCard(
                    icon: Icons.access_time_rounded,
                    label: _dueTime == null
                        ? 'Pick Time'
                        : _dueTime!.format(context),
                    hasValue: _dueTime != null,
                    onTap: _dueDate != null ? _pickTime : null,
                    onClear: _dueTime != null
                        ? () => setState(() => _dueTime = null)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder toggle
            if (_dueDate != null)
              Card(
                child: SwitchListTile(
                  secondary: Icon(Icons.notifications_rounded,
                      color: _hasReminder
                          ? colorScheme.primary
                          : colorScheme.outline),
                  title: const Text('Set Reminder'),
                  subtitle: Text(
                    _hasReminder
                        ? 'You\'ll be notified when due'
                        : 'No reminder set',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  value: _hasReminder,
                  onChanged: (val) => setState(() => _hasReminder = val),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? finalDue;
    if (_dueDate != null) {
      final t = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
      finalDue = DateTime(
          _dueDate!.year, _dueDate!.month, _dueDate!.day, t.hour, t.minute);
    }

    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      provider.updateTask(widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: finalDue,
        hasReminder: _hasReminder,
      ));
    } else {
      provider.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: finalDue,
        hasReminder: _hasReminder,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Task updated!' : 'Task added!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                )),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final Priority priority;
  final bool isSelected;
  final VoidCallback onTap;
  const _PriorityChip(
      {required this.priority,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFFC107),
      const Color(0xFFF44336),
    ];
    final color = colors[priority.index];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(priority.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              priority.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.category,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      avatar: Text(category.emoji),
      label: Text(category.label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }
}

class _PickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _PickerCard({
    required this.icon,
    required this.label,
    required this.hasValue,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: hasValue
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: isDisabled ? 0.2 : 0.4),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: hasValue
                    ? colorScheme.primary
                    : colorScheme.onSurface
                        .withValues(alpha: isDisabled ? 0.3 : 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? colorScheme.primary
                      : colorScheme.onSurface
                          .withValues(alpha: isDisabled ? 0.3 : 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 16, color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
