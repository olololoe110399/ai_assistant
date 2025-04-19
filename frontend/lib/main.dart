import 'package:flutter/material.dart';
import 'src/di.dart';
import 'src/presentation/ui/voice_chat_page.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VoiceChatPage(),
    );
  }
}
