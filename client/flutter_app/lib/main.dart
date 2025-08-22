import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/server_io.dart';

// The provider and notifier class from the previous step go here.

void main() {
  runApp(const ProviderScope(child: WebSocketDemo()));
}

class WebSocketDemo extends ConsumerStatefulWidget {
  const WebSocketDemo({super.key});

  @override
  ConsumerState<WebSocketDemo> createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends ConsumerState<WebSocketDemo> {
  final ScrollController _scrollController = ScrollController();

  // Helper method to auto-scroll
  void _scrollToBottom() {
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
  void initState() {
    super.initState();
    // Listen for state changes and scroll
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(serverIOProvider, (_, __) {
      _scrollToBottom();
    });
    // Watch the provider's state
    final asyncMessages = ref.watch(serverIOProvider);
    final notifier = ref.read(serverIOProvider.notifier);
    final connected = notifier.connected;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("WebSocket Demo")),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: connected
                      ? notifier.disconnectFromServer
                      : notifier.connectToServer,
                  child: Text(connected ? "Disconnect" : "Connect"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: connected ? notifier.sendProcess : null,
                  child: const Text("Send Process"),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black87,
                child: asyncMessages.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (messages) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        if (messages[index] == "@Divider") {
                          return const Divider(
                            thickness: 2,
                            color: Colors.grey,
                          );
                        }
                        return Text(
                          messages[index],
                          style: const TextStyle(color: Colors.white),
                        );
                      },
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
