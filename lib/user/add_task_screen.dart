import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTaskScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> newTask) addTaskCallback;
  final userEmail;
  const AddTaskScreen(
      {Key? key, required this.addTaskCallback, required this.userEmail})
      : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Send an HTTP request to the API to create the task
      final response = await http.post(
        Uri.parse(
            'http://172.20.10.3/flutter_communicating_api/create_task.php'),
        body: {
          'title': _title,
          'description': _description,
          'assigned_to': widget.userEmail,
        },
      );

      // Parse the JSON response and show a snackbar with the message
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );

      // Create a new map representing the new task and pass it back to the parent widget
      final newTask = {
        'id': data['id'],
        'title': _title,
        'description': _description,
        'assigned_to': widget.userEmail,
      };
      widget.addTaskCallback(newTask);

      // Navigate back to the user home screen
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  _submitForm();
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
