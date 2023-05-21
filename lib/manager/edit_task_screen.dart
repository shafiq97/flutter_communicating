import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EditTaskManagerScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic> updatedTask) editTaskCallback;

  const EditTaskManagerScreen({
    Key? key,
    required this.task,
    required this.editTaskCallback,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditTaskManagerScreenState createState() => _EditTaskManagerScreenState();
}

class _EditTaskManagerScreenState extends State<EditTaskManagerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<Map<String, dynamic>> _employees = [];
  String? _selectedAssignee;
  String? _selectedPriority;
  bool _isTaskCompleted = false;

  void sendEmailNotification(
      String recipientEmail, String subject, String message) async {
    // Configure the SMTP server details (Mailtrap)
    final smtpServer = gmail("muhammadshafiq457@gmail.com", "vybjkqrynlszagnj");

    // Create the email message
    final message = Message()
      ..from = const Address('task-management-admin@gmail.com', 'Admin@NoReply')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = "This is to inform that a new task has been assigned to you";

    try {
      final sendReport = await send(message, smtpServer);
      log('Message sent: $sendReport');
    } on MailerException catch (e) {
      log('Message not sent.');
      log(e.toString());
      for (var p in e.problems) {
        log('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  late Future<void> _employeesFuture;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with the task data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _isTaskCompleted = widget.task['completed'] == '1';
    if (widget.task['assigned_to'].toString().isNotEmpty) {
      _selectedAssignee = widget.task['assigned_to'];
    }
    _selectedPriority = widget.task['priority'];
    // Fetch the list of employees for the dropdown menu
    _employeesFuture = _fetchEmployees();
  }

  @override
  void dispose() {
    // Dispose the text controllers when the screen is closed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_employees.php');

    // Send an HTTP request to the API to fetch the employees
    final response = await http.get(uri);

    // Parse the JSON response and set the list of employees
    final data = jsonDecode(response.body);
    final employees = List<Map<String, dynamic>>.from(data['employees']
        .map((employee) => Map<String, dynamic>.from(employee)));

    // Use a Set to store unique email addresses
    final uniqueEmails = <String>{};

    // Filter out employees with duplicate email addresses
    final uniqueEmployees = employees.where((employee) {
      final email = employee['email'];

      // If the email is already in the set, skip this employee
      if (uniqueEmails.contains(email)) {
        return false;
      }

      // Otherwise, add the email to the set and include this employee
      uniqueEmails.add(email);
      return true;
    }).toList();

    setState(() {
      _employees = uniqueEmployees;

      // Check if _selectedAssignee is in the list of employees' emails
      if (_selectedAssignee != null &&
          !_employees
              .map((employee) => employee['email'])
              .contains(_selectedAssignee)) {
        _selectedAssignee = null;
      }
    });
  }

  void _updateTask() async {
    // Send an HTTP request to update the task
    log(widget.task['id']);
    log(_titleController.text);
    log(_descriptionController.text);
    log(_selectedAssignee ?? 'asas');
    log(_isTaskCompleted.toString());
    if (_selectedAssignee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee')),
      );
      return;
    }
    final response = await http.post(
      Uri.parse(
          'http://192.168.68.100/flutter_communicating_api/update_task.php'),
      body: {
        'id': widget.task['id'].toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'assignee': _selectedAssignee ?? '',
        'completed': _isTaskCompleted ? '1' : '0',
        'priority': _selectedPriority ?? 'Low', // default value is 'Low'
      },
    );

    // Send an email notification to the assignee
    sendEmailNotification(
      _selectedAssignee ?? '',
      'Task Updated',
      'The task has been updated.',
    );

    // Parse the JSON response and show a snackbar with the message
    final data = jsonDecode(response.body);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );

    // Call the edit task callback with the updated task data
    widget.editTaskCallback({
      'id': widget.task['id'],
      'title': _titleController.text,
      'description': _descriptionController.text,
      'assignee': _selectedAssignee,
      'priority': _selectedPriority,
      'completed': _isTaskCompleted
    });

    _fetchEmployees();

    // Close the screen
    // ignore: use_build_context_synchronously
    // Navigator.pushNamed(context, '/employee');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // show a loading spinner while waiting
            } else if (snapshot.hasError) {
              // If there's an error, display a text message
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
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
                    decoration: InputDecoration(
                      labelText: 'Assignee',
                      helperText: _selectedAssignee == null
                          ? 'Please select an assignee'
                          : null,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Please select an assignee'),
                      ),
                      ..._employees.map((employee) {
                        return DropdownMenuItem<String>(
                          value: employee['email'],
                          child: Text(employee['name']),
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      helperText: _selectedPriority == null
                          ? 'Please select a priority'
                          : null,
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Please select a priority'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'High',
                        child: Text('High'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Medium',
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Low',
                        child: Text('Low'),
                      ),
                    ],
                  ),
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
              );
            }
          },
        ),
      ),
    );
  }
}
