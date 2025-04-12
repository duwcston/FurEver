import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
final String projectID = dotenv.env['GOOGLE_PROJECT_ID'] ?? '';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      await Future.delayed(
        Duration(milliseconds: 200),
      ); // Simulating async operation
      setState(() {
        _messages.add({"role": "user", "text": userMessage});
        _controller.clear();
      });
    }
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $geminiApiKey',
      'x-goog-user-project': projectID,
    };
    final data = {
      "contents": [
        {
          "parts": [
            {"text": userMessage},
          ],
        },
      ],
    };
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/tunedModels/dogdiseaseprediction-d38f6lnraqya:generateContent',
    );
    try {
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final candidate = jsonData['candidates'][0];
        final content = candidate['content'];
        final part = content['parts'];
        final text = part[0]['text'];
        setState(() {
          _messages.add({"role": "ai", "text": text});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "ai",
            "text": "Error: Unable to fetch response",
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Error: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Box')),
      body: SafeArea(child: Column(children: [_messageField(), _inputField()])),
    );
  }

  Padding _inputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () async => await _sendMessage(),
          ),
        ],
      ),
    );
  }

  Expanded _messageField() {
    final ScrollController scrollController = ScrollController();

    // Scroll to bottom after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messages.isNotEmpty) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isUserMessage = message['role'] == 'user';

          return Align(
            alignment:
                isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message['text']!,
                style: TextStyle(
                  color: isUserMessage ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
