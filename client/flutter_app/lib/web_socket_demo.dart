import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/log_view.dart';
import 'providers/server_io.dart';

class WebSocketDemo extends ConsumerWidget {
  const WebSocketDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(serverIOProvider.notifier);

    final isConnected = ref
        .watch(serverIOProvider)
        .whenOrNull(data: (serverIO) => serverIO.isConnected);

    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket Demo")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              ElevatedButton(
                onPressed: isConnected == null
                    ? null
                    : isConnected
                    ? notifier.disconnectFromServer
                    : notifier.connect,
                child: Text(
                  isConnected == null
                      ? "Wait"
                      : isConnected
                      ? "Disconnect"
                      : "Connect",
                ),
              ),

              ElevatedButton(
                onPressed: isConnected == true ? notifier.sendProcess : null,
                child: const Text("Send Process"),
              ),
            ],
          ),

          const Divider(),
          Expanded(child: LogView()),
        ],
      ),
    );
  }
}
