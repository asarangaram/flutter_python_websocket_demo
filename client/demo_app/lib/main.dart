import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebSocketPage(),
    );
  }
}

class WebSocketPage extends StatefulWidget {
  const WebSocketPage({super.key});

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  // Use your computer's IP address. For Android emulator, use 10.0.2.2.
  // For iOS simulator or physical device, find your computer's local IP.
  // Example: 'ws://192.168.1.100:5000/socket.io/?EIO=4&transport=websocket'
  final String _serverIp = '192.168.0.179';
  final String _serverPort = '5002';

  // The 'io' transport is required for Socket.IO compatibility
  late WebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  String _message = 'No message yet.';

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    try {
      // The Socket.IO protocol requires a specific path.
      final String uri =
          'ws://$_serverIp:$_serverPort/socket.io/?EIO=4&transport=websocket';
      channel = IOWebSocketChannel.connect(Uri.parse(uri));

      // Listen for messages from the server.
      channel.stream.listen(
        (data) {
          setState(() {
            _message = 'Received: $data';
          });
          print('Received from server: $data');
        },
        onError: (error) {
          setState(() {
            _message = 'Error: $error';
          });
          print('WebSocket error: $error');
        },
        onDone: () {
          setState(() {
            _message = 'Connection closed.';
          });
          print('WebSocket connection closed.');
        },
      );
    } catch (e) {
      setState(() {
        _message = 'Failed to connect: $e';
      });
      print('Failed to connect to server: $e');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // Create the payload. The 'type' and 'data' fields are part of the
      // Socket.IO protocol.
      String messageToSend =
          '42["my_message", {"data": "${_controller.text}"}]';
      channel.sink.add(messageToSend);
      _controller.clear();
      setState(() {
        _message = 'Sent: $messageToSend';
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Demo')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send Message to Server'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Server Response:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: SingleChildScrollView(child: Text(_message))),
          ],
        ),
      ),
    );
  }
}
