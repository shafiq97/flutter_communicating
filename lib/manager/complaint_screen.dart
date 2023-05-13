import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/login.dart';
import '../shared/profile.dart';
import '../user/add_task_screen.dart';

// ignore: must_be_immutable
class ComplaintsScreen extends StatefulWidget {
  String email;
  ComplaintsScreen({Key? key, required this.email}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();

    // Fetch the tasks for the logged-in user
    _fetchTasks();
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

  Future<List<Map<String, dynamic>>> _fetchComplaints(String taskId) async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_complaints.php');

    // Send an HTTP request to the API to fetch the complaints
    final response = await http.post(uri, body: {'task_id': taskId.toString()});

    // Parse the JSON response and return the list of complaints
    final data = jsonDecode(response.body);
    final complaints = List<Map<String, dynamic>>.from(data['complaints']
        .map((complaint) => Map<String, dynamic>.from(complaint)));
    return complaints;
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
        title: const Text('Employees Complaints'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Task Management',
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
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchComplaints(task['id']),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ExpansionTile(
                        title: Text(task['title']),
                        subtitle: Text(task['assigned_to']),
                        children: snapshot.data!.map<Widget>((complaint) {
                          return ListTile(
                            title: Text(complaint['complaint_message']),
                            subtitle: Text(complaint['complainer_email']),
                          );
                        }).toList(),
                      );
                    }
                  },
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
