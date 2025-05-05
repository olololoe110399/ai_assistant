import 'package:flutter/material.dart';
import 'package:flutter_client/features/voice_chat/presentation/presentation.dart';
import 'package:flutter_client/features/voice_chat/presentation/widgets/animated_blob.dart';
import 'package:flutter_client/features/voice_chat/presentation/widgets/waveform.dart';
import 'package:provider/provider.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int speed = 3;
  double size = 300;
  @override
  void initState() {
    final vm = context.read<VoiceChatProvider>();
    vm.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VoiceChatProvider>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text('Gemini Voice Chat')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              AnimatedBlob(
                key: ValueKey(speed + size),
                size: size,
                speed: speed,
              ),
              const Spacer(),
              Text(vm.isStreaming ? 'Streaming...' : 'Press Start'),
              const SizedBox(height: 20),
              WaveForm(amplitudeStream: vm.stream),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: vm.isStreaming ? vm.stop : vm.start,
                    child: Text(vm.isStreaming ? 'Stop' : 'Start'),
                  ),
                  vm.mapTools != null
                      ? ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            useSafeArea: true,
                            isScrollControlled: true,
                            context: scaffoldKey.currentContext!,
                            builder:
                                (_) => Image.network(
                                  vm.mapTools!.url,
                                  fit: BoxFit.cover,
                                ),
                          );
                        },
                        child: Icon(Icons.map, color: Colors.green),
                      )
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
