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
    });

    socket!.on("message", (data) {
      final msg = data["msg"];
      addMessage("📩 $msg");

      if (msg == "done") {
        addMessage("Process finished!");
      }
    });

    socket!.onDisconnect((_) {
      setState(() => connected = false);
      addMessage("❌ Disconnected");
      addMessage("@Divider");
      socket!.dispose(); // cleans up listeners
      socket = null;
    });
  }

  void disconnectFromServer() {
    if (socket != null) {
      socket?.disconnect();
      socket?.dispose(); // cleans up listeners
      socket = null;
    }
  }

  void sendProcess() {
    if (socket != null && connected) {
      socket!.emit("message", "process");
      addMessage("▶ Sent 'process' to server");
    }
  }

  void addMessage(String msg) {
    setState(() {
      messages.add(msg);
    });

    // Auto-scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: connected ? disconnectFromServer : connectToServer,
                  child: Text(connected ? "Disconnect" : "Connect"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: connected ? sendProcess : null,
                  child: const Text("Send Process"),
                ),
              ],
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
                    if (messages[index] == "@Divider") {
                      return Divider(
                        thickness: 2, // line thickness
                        color: Colors.grey,
                      );
                    }
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
