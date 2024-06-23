enum TodoStatus { todo, inProgress, done, bug }

class TodoItem {
  int? id;
  String title;
  String description;
  TodoStatus status;

  TodoItem({
    this.id,
    required this.title,
    required this.description,
    this.status = TodoStatus.todo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: TodoStatus.values[map['status']],
    );
  }
}
