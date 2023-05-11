import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  const ProfileScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user data and set the values of _nameController and _emailController
    _emailController.text = widget.userEmail;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final Uri uri = Uri.parse(
        'http://172.20.10.3/flutter_communicating_api/get_profile.php?email=${widget.userEmail}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['name'];
        _emailController.text = data['email'];
      });
    } else {
      // Handle API errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to fetch user data')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    // Send an HTTP request to the save_profile API
    final response = await http.post(
      Uri.parse(
          'http://172.20.10.3/flutter_communicating_api/save_profile.php'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
      },
    );

    if (response.body.isNotEmpty) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      // Handle null response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No response from server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name:'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 16),
            const Text('Email:'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Enter your email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}