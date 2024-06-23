import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/todo_item.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TodoStatus _selectedStatus = TodoStatus.todo;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await dbHelper.getTasks();
    setState(() {
      _todoItems.addAll(tasks);
    });
  }

  void _addOrUpdateTodoItem({TodoItem? item}) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        if (item == null) {
          final newItem = TodoItem(
            title: _titleController.text,
            description: _descriptionController.text,
            status: _selectedStatus,
          );
          _todoItems.add(newItem);
          dbHelper.insertTask(newItem);
        } else {
          item.title = _titleController.text;
          item.description = _descriptionController.text;
          item.status = _selectedStatus;
          dbHelper.updateTask(item);
        }
      });
      _titleController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showTodoDialog({TodoItem? item}) {
    if (item != null) {
      _titleController.text = item.title;
      _descriptionController.text = item.description;
      _selectedStatus = item.status;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _selectedStatus = TodoStatus.todo;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Ajouter' : 'Modifier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<TodoStatus>(
                value: _selectedStatus,
                onChanged: (TodoStatus? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                items: TodoStatus.values
                    .map<DropdownMenuItem<TodoStatus>>((TodoStatus status) {
                  return DropdownMenuItem<TodoStatus>(
                    value: status,
                    child: Row(
                      children: [
                        Icon(_getIconForStatus(status),
                            color: _getColorForStatus(status)),
                        SizedBox(width: 8),
                        Text(_getTextForStatus(status)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addOrUpdateTodoItem(item: item);
              },
              child: Text(item == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _changeTodoStatus(TodoItem item, TodoStatus newStatus) {
    setState(() {
      item.status = newStatus;
      dbHelper.updateTask(item);
    });
  }

  String _getTextForStatus(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return 'Todo';
      case TodoStatus.inProgress:
        return 'In progress';
      case TodoStatus.done:
        return 'Done';
      case TodoStatus.bug:
        return 'Bug';
    }
  }

  Color _getColorForStatus(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Colors.grey;
      case TodoStatus.inProgress:
        return Colors.blue;
      case TodoStatus.done:
        return Colors.green;
      case TodoStatus.bug:
        return Colors.red;
    }
  }

  IconData _getIconForStatus(TodoStatus status) {
    switch (status) {
      case TodoStatus.todo:
        return Icons.list;
      case TodoStatus.inProgress:
        return Icons.work;
      case TodoStatus.done:
        return Icons.done;
      case TodoStatus.bug:
        return Icons.bug_report;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                final item = _todoItems[index];
                return TodoItemWidget(
                  item: item,
                  onStatusChanged: _changeTodoStatus,
                  onEdit: () => _showTodoDialog(item: item),
                  getColorForStatus: _getColorForStatus,
                  getIconForStatus: _getIconForStatus,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

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
