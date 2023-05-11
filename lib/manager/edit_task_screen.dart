import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTaskManagerScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic> updatedTask) editTaskCallback;

  const EditTaskManagerScreen({
    Key? key,
    required this.task,
    required this.editTaskCallback,
  }) : super(key: key);

  @override
  _EditTaskManagerScreenState createState() => _EditTaskManagerScreenState();
}

class _EditTaskManagerScreenState extends State<EditTaskManagerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<Map<String, dynamic>> _employees = [];
  String? _selectedAssignee;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the task data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);

    // Fetch the list of employees for the dropdown menu
    _fetchEmployees();
  }

  @override
  void dispose() {
    // Dispose the text controllers when the screen is closed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fetchEmployees() async {
    final Uri uri = Uri.parse(
        'http://172.20.10.3/flutter_communicating_api/get_employees.php');

    // Send an HTTP request to the API to fetch the employees
    final response = await http.get(uri);

    // Parse the JSON response and set the list of employees
    final data = jsonDecode(response.body);
    final employees = List<Map<String, dynamic>>.from(data['employees']
        .map((employee) => Map<String, dynamic>.from(employee)));
    setState(() {
      _employees = employees;
    });
  }

  void _updateTask() async {
    // Send an HTTP request to update the task
    log(widget.task['id']);
    log(_titleController.text);
    log(_descriptionController.text);
    log(_selectedAssignee ?? '');

    final response = await http.post(
      Uri.parse('http://172.20.10.3/flutter_communicating_api/update_task.php'),
      body: {
        'id': widget.task['id'].toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'assignee': _selectedAssignee ?? '', // Assignee email or ID
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
      'assignee': _selectedAssignee,
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
            DropdownButtonFormField<String>(
              value: _selectedAssignee,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAssignee = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Assignee',
              ),
              items: _employees.map((employee) {
                return DropdownMenuItem<String>(
                  value: employee['email'],
                  child: Text(employee['name']),
                );
              }).toList(),
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
