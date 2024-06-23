import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/todo_item.dart';
import 'package:flutter_application_2/database/database_helper.dart';

class AddEditTaskPage extends StatefulWidget {
  final TodoItem? item;

  AddEditTaskPage({this.item});

  @override
  _AddEditTaskPageState createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TodoStatus _selectedStatus = TodoStatus.todo;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description;
      _selectedStatus = widget.item!.status;
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }

    final newItem = TodoItem(
      id: widget.item?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _selectedStatus,
    );

    if (widget.item == null) {
      await _dbHelper.insertTask(newItem);
    } else {
      await _dbHelper.updateTask(newItem);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Ajouter' : 'Modifier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.item == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
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
}
