import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  const ProfileScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userEmail;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_profile.php?email=${widget.userEmail}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['name'];
        _emailController.text = data['email'];
        _contactController.text = data['contact'];
      });
    } else {
      // Handle API errors
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Failed to fetch user data')),
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
          'http://192.168.68.100/flutter_communicating_api/save_profile.php'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'contact': _contactController.text
      },
    );

    if (response.body.isNotEmpty) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        // Show error message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      // Handle null response
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No response from server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/profile.json',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
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
              const Text('Contact:'),
              TextFormField(
                controller: _contactController,
                decoration:
                    const InputDecoration(hintText: 'Enter your contact'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
