import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InboxScreen extends StatefulWidget {
  final String userEmail;

  const InboxScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];
  String _filterEmail = '';
  List<String> _emailsList = []; // Declare and initialize _emailsList

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() async {
    final Uri uri = Uri.parse(
        'http://192.168.68.100/flutter_communicating_api/get_messages.php?receiver_email=${widget.userEmail}');

    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    final messages = List<Map<String, dynamic>>.from(
        data['messages'].map((message) => Map<String, dynamic>.from(message)));

    // Extract unique receiver and sender email values
    final uniqueEmails = Set<String>();
    for (final message in messages) {
      final receiverEmail = message['receiver_email'] as String;
      final senderEmail = message['sender_email'] as String;
      uniqueEmails.add(receiverEmail);
      uniqueEmails.add(senderEmail);
    }

    // Convert the unique emails to a list
    final emailsList = uniqueEmails.toList();

    setState(() {
      _messages = messages;
      _isLoading = false;
      _filterEmail = ''; // Reset the filter
      _emailsList = emailsList; // Set the unique emails list
    });
  }

  void _filterMessages(String? email) {
    setState(() {
      _filterEmail = email ?? ''; // Use empty string if email is null
    });
  }

  List<Map<String, dynamic>> getFilteredMessages() {
    if (_filterEmail.isEmpty) {
      return _messages;
    } else {
      return _messages.where((message) {
        final receiverEmail = message['receiver_email'] as String;
        final senderEmail = message['sender_email'] as String;
        return receiverEmail == _filterEmail || senderEmail == _filterEmail;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: DropdownButtonFormField<String>(
                //     value: _filterEmail,
                //     onChanged: _filterMessages,
                //     items: _emailsList
                //         .map<DropdownMenuItem<String>>(
                //           (email) => DropdownMenuItem<String>(
                //             value: email,
                //             child: Text(email),
                //           ),
                //         )
                //         .toList(),
                //     decoration: InputDecoration(
                //       labelText: 'Filter by Receiver Email',
                //     ),
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    itemCount: getFilteredMessages().length,
                    itemBuilder: (context, index) {
                      final message = getFilteredMessages()[index];
                      return ListTile(
                        title: Text('Sender: ${message['sender_email']}'),
                        subtitle: Text('Message: ${message['message']}'),
                        trailing: Text('${message['created_at']}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
