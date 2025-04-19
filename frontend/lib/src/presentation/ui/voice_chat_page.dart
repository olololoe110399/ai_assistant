import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/voice_chat_view_model.dart';

class VoiceChatPage extends StatelessWidget {
  const VoiceChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceChatViewModel(),
      child: Consumer<VoiceChatViewModel>(
        builder:
            (context, vm, _) => Scaffold(
              appBar: AppBar(title: const Text('Gemini Voice Chat')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Status: ${vm.status}'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(vm.running ? Icons.stop : Icons.mic),
                      label: Text(vm.running ? 'Stop' : 'Start'),
                      onPressed: vm.toggle,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
