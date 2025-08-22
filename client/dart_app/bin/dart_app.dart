import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  // Create the socket
  final socket = io.io("http://192.168.0.179:5002", <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": false,
  });

  // Connect event
  socket.onConnect((_) {
    print("Connected to server");

    // Immediately send "process"
    socket.emit("message", "process");
    print("📤 Sent: process");
  });

  // Listen for messages
  socket.on("message", (data) {
    final msg = data["msg"];
    print("$msg");

    if (msg == "done") {
      print("Process completed, disconnecting...");
      socket.disconnect();
    }
  });

  // Disconnect event
  socket.onDisconnect((_) {
    print("Disconnected from server");
  });

  // Connect to the server
  socket.connect();
}
