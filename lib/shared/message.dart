import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String userEmail;

  const MessageScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    String message = _messageController.text;
    // Implement your logic to send the message to the user with the provided email
    print('Sending message to ${widget.userEmail}: $message');
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
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                ),
                maxLines: null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
