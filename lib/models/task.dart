
enum Priority { low, medium, high }

enum Category { personal, work, shopping, health, finance, other }

extension PriorityExtension on Priority {
  String get label => ['Low', 'Medium', 'High'][index];
  String get emoji => ['🟢', '🟡', '🔴'][index];
}

extension CategoryExtension on Category {
  String get label =>
      ['Personal', 'Work', 'Shopping', 'Health', 'Finance', 'Other'][index];
  String get emoji => ['👤', '💼', '🛒', '❤️', '💰', '📌'][index];
}

class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  Priority priority;
  Category category;
  DateTime? dueDate;
  bool hasReminder;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = Category.personal,
    this.dueDate,
    this.hasReminder = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    Category? category,
    DateTime? dueDate,
    bool? hasReminder,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      hasReminder: hasReminder ?? this.hasReminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.index,
        'category': category.index,
        'dueDate': dueDate?.toIso8601String(),
        'hasReminder': hasReminder,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isCompleted: json['isCompleted'] ?? false,
        priority: Priority.values[json['priority'] ?? 1],
        category: Category.values[json['category'] ?? 0],
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        hasReminder: json['hasReminder'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  bool get isOverdue =>
      dueDate != null &&
      !isCompleted &&
      dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}
