import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/server_io.dart';

class LogView extends ConsumerStatefulWidget {
  const LogView({super.key});

  @override
  ConsumerState<LogView> createState() => _LogViewState();
}

class _LogViewState extends ConsumerState<LogView> {
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
  Widget build(BuildContext context) {
    ref.listen(serverIOProvider, (_, __) {
      _scrollToBottom();
    });
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black87,
      child: ref
          .watch(serverIOProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (serverIO) {
              return ListView.builder(
                controller: _scrollController,
                itemCount: serverIO.messages.length,
                itemBuilder: (context, index) {
                  if (serverIO.messages[index] == "@Divider") {
                    return const Divider(thickness: 2, color: Colors.grey);
                  }
                  return Text(
                    serverIO.messages[index],
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
