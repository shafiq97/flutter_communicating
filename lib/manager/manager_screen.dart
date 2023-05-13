import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_comunicating/manager/complaint_screen.dart';
import 'package:http/http.dart' as http;

import '../auth/login.dart';
import '../shared/message.dart';
import '../shared/profile.dart';

class ManagerScreen extends StatefulWidget {
  final String userEmail;
  const ManagerScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _fetchEmployees() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_employees.php');

    // Send an HTTP request to the API to fetch the employees
    final response = await http.get(uri);

    // Parse the JSON response and set the list of employees
    final data = jsonDecode(response.body);
    final employees = List<Map<String, dynamic>>.from(data['employees']
        .map((employee) => Map<String, dynamic>.from(employee)));
    setState(() {
      _employees = employees;
      _isLoading = false;
    });
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
        title: const Text(
          'Employees',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
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
              accountEmail: Text(widget.userEmail),
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
                    arguments: widget.userEmail);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Complaints'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ComplaintsScreen(email: widget.userEmail),
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
                        ProfileScreen(userEmail: widget.userEmail),
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
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final employee = _employees[index];
                return Dismissible(
                  key: Key(employee['id'].toString()),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) async {
                    // Send an HTTP request to delete the employee
                    final response = await http.post(
                      Uri.parse(
                          'http://192.168.68.100/flutter_communicating_api/delete_employee.php'),
                      body: {
                        'id': employee['id'].toString(),
                      },
                    );

                    // Parse the JSON response and show a snackbar with the message
                    final data = jsonDecode(response.body);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'])),
                    );

                    // Update the list of employees
                    setState(() {
                      _employees.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(employee['name']),
                    subtitle: Text(employee['email']),
                    trailing: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              userEmail: employee['email'],
                              senderEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
