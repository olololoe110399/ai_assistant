import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/voice_chat/presentation/provider/voice_chat_provider.dart';
import 'features/voice_chat/presentation/screens/voice_chat_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VoiceChatProvider(),
      child: MaterialApp(home: VoiceChatScreen()),
    ),
  );
}
