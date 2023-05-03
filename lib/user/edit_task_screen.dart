import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic> updatedTask) editTaskCallback;

  const EditTaskScreen({
    Key? key,
    required this.task,
    required this.editTaskCallback,
  }) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the task data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
  }

  @override
  void dispose() {
    // Dispose the text controllers when the screen is closed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTask() async {
    // Send an HTTP request to update the task
    final response = await http.post(
      Uri.parse(
          'http://192.168.50.91/flutter_communicating_api/update_task.php'),
      body: {
        'id': widget.task['id'].toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
      },
    );

    // Parse the JSON response and show a snackbar with the message
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );

    // Call the edit task callback with the updated task data
    widget.editTaskCallback({
      'id': widget.task['id'],
      'title': _titleController.text,
      'description': _descriptionController.text,
    });

    // Close the screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
