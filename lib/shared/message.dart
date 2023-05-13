import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageScreen extends StatefulWidget {
  final String userEmail;
  final String senderEmail;

  const MessageScreen(
      {Key? key, required this.userEmail, required this.senderEmail})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    String message = _messageController.text;
    String senderEmail = widget.senderEmail; // Replace with the sender's email
    String receiverEmail = widget.userEmail; // Receiver's email

    // Prepare the message data
    Map<String, dynamic> messageData = {
      'sender_email': senderEmail,
      'receiver_email': receiverEmail,
      'message': message,
    };

    // Send an HTTP request to insert the message
    final response = await http.post(
      Uri.parse(
          'http://192.168.68.100/flutter_communicating_api/send_message.php'),
      body: jsonEncode(messageData),
      headers: {'Content-Type': 'application/json'},
    );

    // Parse the JSON response
    final data = jsonDecode(response.body);

    // Display a snackbar with the response message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message to ${widget.userEmail}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                ),
                maxLines: null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
