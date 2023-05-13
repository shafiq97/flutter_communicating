import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/login.dart';
import '../shared/profile.dart';
import '../user/add_task_screen.dart';
import 'complaint_screen.dart';
import 'edit_task_screen.dart';

// ignore: must_be_immutable
class ManagerManageTasks extends StatefulWidget {
  String email;
  ManagerManageTasks({Key? key, required this.email}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ManagerManageTasksState createState() => _ManagerManageTasksState();
}

class _ManagerManageTasksState extends State<ManagerManageTasks> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];

  late final TextEditingController _progressController;
  @override
  void initState() {
    super.initState();
    // Fetch the tasks for the logged-in user
    _fetchTasks();
  }

  double _getProgressValue() {
    if (_progressController.text.isEmpty) {
      return 0;
    }

    int progress = int.parse(_progressController.text);
    return progress / 100.0;
  }

  void _fetchTasks() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_tasks.php');

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

  // ignore: unused_element
  void _addTask(Map<String, dynamic> newTask) {
    setState(() {
      _tasks.add(newTask);
    });
  }

  // ignore: unused_element
  void _navigateToAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          userEmail: widget.email,
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
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Project and Task Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(widget.email),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Summary'),
              onTap: () {
                Navigator.pushNamed(context, '/manager_dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.pushNamed(context, '/manager_task_screen',
                    arguments: widget.email);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintsScreen(email: widget.email),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userEmail: widget.email),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _showLogoutConfirmationDialog();
              },
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
                          'http://192.168.68.100/flutter_communicating_api/delete_task.php'),
                      body: {
                        'id': task['id'].toString(),
                      },
                    );

                    // Parse the JSON response and show a snackbar with the message
                    final data = jsonDecode(response.body);
                    // ignore: use_build_context_synchronously
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
                          builder: (context) => EditTaskManagerScreen(
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task['description']),
                          const SizedBox(height: 4.0),
                          Text('Assignee: ${task['assigned_to']}'),
                          const SizedBox(height: 4.0),
                          Text(
                              'Status: ${task['completed'] == '1' ? 'Completed' : 'Not Complete'}'),
                          const SizedBox(height: 4.0),
                          LinearProgressIndicator(
                            value: int.parse(task['progress']) /
                                100.0, // Normalized progress value
                            backgroundColor: Colors.grey[200],
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _navigateToAddTaskScreen,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
