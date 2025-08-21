import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const WebSocketDemo());
}

class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});

  @override
  State<WebSocketDemo> createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  IO.Socket? socket;
  final List<String> messages = [];
  bool connected = false;

  final ScrollController _scrollController = ScrollController();

  void connectToServer() {
    if (socket != null) {
      socket!.dispose(); // cleans up listeners
      socket = null;
    }
    socket = IO.io("http://192.168.0.179:5002", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      setState(() => connected = true);
      addMessage("✅ Connected to server");
      socket!.emit("message", "Hello from Flutter!");
    });

    socket!.on("message", (data) {
      final msg = data["msg"];
      addMessage("📩 $msg");
      print(msg);

      if (msg == "close_connection") {
        print("Closing connection as instructed by server...");
        socket!.disconnect();
      }
    });

    socket!.onDisconnect((_) {
      setState(() => connected = false);
      addMessage("❌ Disconnected");
      addMessage("________");
      addMessage(" ");
    });
  }

  void addMessage(String msg) {
    setState(() {
      messages.add(msg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("WebSocket Demo")),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: connected ? null : connectToServer,
              child: Text(connected ? "Connected" : "Connect"),
            ),
            const Divider(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black87,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Text(
                      messages[index],
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
