import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';

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
  bool _isTaskCompleted = false;

  // void sendEmailNotification(
  //     String recipientEmail, String subject, String message) async {
  //   // Configure the SMTP server details (Mailtrap)
  //   final smtpServer = SmtpServer('smtp.mailtrap.io',
  //       port: 587,
  //       username: 'YOUR_MAILTRAP_USERNAME',
  //       password: 'YOUR_MAILTRAP_PASSWORD',
  //       securityEnabled: true);

  //   // Create the email message
  //   final message = Message()
  //     ..from = Address('your-email@example.com', 'Your Name')
  //     ..recipients.add(recipientEmail)
  //     ..subject = subject
  //     ..text = message;

  //   try {
  //     // Send the email
  //     final sendReport = await send(message, smtpServer);

  //     // Check if the email was sent successfully
  //     if (sendReport.sent) {
  //       print('Email notification sent to $recipientEmail');
  //     } else {
  //       print('Failed to send email notification');
  //     }
  //   } catch (e) {
  //     print('Error sending email notification: $e');
  //   }
  // }

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the task data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _isTaskCompleted = widget.task['completed'] == '1';

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
        'assignee': _selectedAssignee ?? '',
        'completed': _isTaskCompleted ? '1' : '0',
      },
    );

    // Send an email notification to the assignee
    // sendEmailNotification(
    //   _selectedAssignee ?? '',
    //   'Task Updated',
    //   'The task has been updated.',
    // );

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
            CheckboxListTile(
              title: const Text('Task Completed'),
              value: _isTaskCompleted,
              onChanged: (bool? value) {
                setState(() {
                  _isTaskCompleted = value ?? false;
                });
              },
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
