import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'web_socket_demo.dart';

// The provider and notifier class from the previous step go here.

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: WebSocketDemo())));
}
