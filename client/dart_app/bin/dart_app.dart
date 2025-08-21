import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  print('1. Attempting to connect to the WebSocket server...');
  final String serverIp = '192.168.0.179';
  final String serverPort = '5002';
  final wsUrl = Uri.parse(
    'ws://$serverIp:$serverPort/socket.io/?EIO=4&transport=websocket',
  );
  final channel = WebSocketChannel.connect(wsUrl);

  await channel.ready;
  print('2. Connection established. Waiting for a message from the server...');

  channel.stream.listen(
    (message) {
      print('3. A message was received: $message');

      // Send a reply
      channel.sink.add('received!');
      print('4. Sent a reply and now closing the connection.');
      if (message == 'close now') {
        // This is the command that initiates the connection termination.
        channel.sink.close(status.goingAway);
      } else {
        print("Waiting for more messages");
      }
    },
    onDone: () {
      // This callback fires after the connection has been fully closed.
      print('5. The WebSocket connection has been closed.');
    },
    onError: (error) {
      print('Error during communication: $error');
    },
  );
}
