import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

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
  late final TextEditingController _progressController;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the task data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _progressController = TextEditingController(text: widget.task['progress']);
  }

  @override
  void dispose() {
    // Dispose the text controllers when the screen is closed
    _titleController.dispose();
    _descriptionController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  double _getProgressValue() {
    if (_progressController.text.isEmpty) {
      return 0;
    }

    int progress = int.parse(_progressController.text);
    return progress / 100.0;
  }

  void _updateTask() async {
    // Send an HTTP request to update the task
    log(widget.task['id'].toString());
    log(_titleController.text);
    log(_descriptionController.text);
    log(_progressController.text);
    final response = await http.post(
      Uri.parse(
          'http://192.168.68.100/flutter_communicating_api/update_task.php'),
      body: {
        'id': widget.task['id'].toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'progress': _progressController.text,
        'completed': '0',
        'assignee': widget.task['assignee'].toString()
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
      'progress': _progressController.text,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset(
                'assets/task.json',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 150.0),
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
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: _progressController,
                decoration: const InputDecoration(
                  labelText: 'Progress %',
                ),
                maxLines: null,
              ),
              // Progress bar
              LinearProgressIndicator(
                value: _getProgressValue(),
                backgroundColor: Colors.grey, // The color of the track
                color: Colors.green, // The color of the progress bar
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateTask,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
