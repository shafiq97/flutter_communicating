class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final String completed;
  final String assignee;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.completed,
    required this.assignee,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'].toString(),
      description: json['description'].toString(),
      status: json['status'].toString(),
      completed: json['completed'].toString(),
      assignee: json['assigned_to'].toString(),
    );
  }
}
