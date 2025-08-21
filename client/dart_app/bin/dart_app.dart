import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  final socket = IO.io("http://192.168.0.179:5002", <String, dynamic>{
    "transports": ["websocket"],
  });

  socket.onConnect((_) {
    print("Connected to server");
  });

  socket.on("message", (data) {
    final msg = data["msg"];
    print("Message from server: $msg");
    if (msg == "close_connection") {
      print("Closing connection as instructed by server...");
      socket.disconnect();
    }
  });

  socket.onDisconnect((_) {
    print("Disconnected from server");
  });
}
