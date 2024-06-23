import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem item;
  final Function(TodoItem, TodoStatus) onStatusChanged;
  final VoidCallback onEdit;
  final Color Function(TodoStatus) getColorForStatus;
  final IconData Function(TodoStatus) getIconForStatus;

  TodoItemWidget({
    required this.item,
    required this.onStatusChanged,
    required this.onEdit,
    required this.getColorForStatus,
    required this.getIconForStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: IconButton(
          icon: Icon(getIconForStatus(item.status),
              color: getColorForStatus(item.status)),
          onPressed: () {
            TodoStatus newStatus;
            switch (item.status) {
              case TodoStatus.todo:
                newStatus = TodoStatus.inProgress;
                break;
              case TodoStatus.inProgress:
                newStatus = TodoStatus.done;
                break;
              case TodoStatus.done:
                newStatus = TodoStatus.bug;
                break;
              case TodoStatus.bug:
                newStatus = TodoStatus.todo;
                break;
            }
            onStatusChanged(item, newStatus);
          },
        ),
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
