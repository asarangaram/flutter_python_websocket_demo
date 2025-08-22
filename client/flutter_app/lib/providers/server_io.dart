import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final serverIOProvider = AsyncNotifierProvider<ServerIONotifier, List<String>>(
  ServerIONotifier.new,
);

class ServerIONotifier extends AsyncNotifier<List<String>> {
  io.Socket? _socket;
  bool _connected = false;
  final List<String> _messages = [];

  @override
  Future<List<String>> build() async {
    return _messages;
  }

  bool get connected => _connected;

  void connectToServer() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    _socket = io.io("http://192.168.0.179:5002", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _connected = true;
      addMessage("✅ Connected to server");
    });

    _socket!.on("message", (data) {
      final msg = data["msg"];
      addMessage("📩 $msg");

      if (msg == "done") {
        addMessage("Process finished!");
      }
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      addMessage("❌ Disconnected");
      addMessage("@Divider");
      _socket!.dispose();
      _socket = null;
    });
  }

  void disconnectFromServer() {
    if (_socket != null) {
      _socket?.disconnect();
      _socket?.dispose();
      _connected = false;
      _socket = null;
    }
  }

  void sendProcess() {
    if (_socket != null && _connected) {
      _socket!.emit("message", "process");
      addMessage("▶ Sent 'process' to server");
    }
  }

  void addMessage(String msg) {
    _messages.add(msg);
    // Update the state to notify listeners
    state = AsyncData([..._messages]);
  }
}
