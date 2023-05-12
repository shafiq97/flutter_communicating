import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/login.dart';
import '../shared/profile.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'inbox.dart';

class UserHomeScreen extends StatefulWidget {
  final String userEmail;
  const UserHomeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();

    // Fetch the tasks for the logged-in user
    _fetchTasks();
  }

  void _fetchTasks() async {
    const String email =
        'shafiq@gmail.com'; // Replace with the email address of the logged-in user
    final Uri uri = Uri.parse(
        'http://172.20.10.3/flutter_communicating_api/get_tasks.php?email=$email');

    // Send an HTTP request to the API to fetch the tasks
    final response = await http.get(uri);

    // Parse the JSON response and set the list of tasks
    final data = jsonDecode(response.body);
    final tasks = List<Map<String, dynamic>>.from(
        data['tasks'].map((task) => Map<String, dynamic>.from(task)));
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void addTaskCallback() {
    setState(() {
      _fetchTasks();
    });
  }

  void _addTask(Map<String, dynamic> newTask) {
    setState(() {
      _tasks.add(newTask);
    });
  }

  void _navigateToAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          addTaskCallback: (newTask) {
            setState(() {
              _tasks.add(newTask);
            });
          },
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userEmail: widget.userEmail),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Inbox'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InboxScreen(userEmail: widget.userEmail),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _showLogoutConfirmationDialog,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task['id'].toString()),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) async {
                    // Send an HTTP request to delete the task
                    final response = await http.post(
                      Uri.parse(
                          'http://172.20.10.3/flutter_communicating_api/delete_task.php'),
                      body: {
                        'id': task['id'].toString(),
                      },
                    );

                    // Parse the JSON response and show a snackbar with the message
                    final data = jsonDecode(response.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'])),
                    );

                    // Update the list of tasks
                    setState(() {
                      _tasks.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                            task: task,
                            editTaskCallback: (editedTask) {
                              setState(() {
                                _tasks[index] = editedTask;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(task['title']),
                      subtitle: Text(task['description']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
