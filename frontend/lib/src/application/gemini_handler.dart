import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_client/src/domain/audio_processor.dart';
import 'package:flutter_client/src/domain/buffer_drainer.dart';

import '../config.dart';
import '../domain/interfaces.dart';
import '../infrastructure/websocket_service.dart';
import '../infrastructure/audio_player.dart';
import '../infrastructure/audio_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class GeminiHandler {
  final GeminiConfig config;
  final IAudioProcessor processor;
  final IBufferDrainer drainer;
  final WebSocketService socket;
  final AudioPlayerService player;
  final AudioRecorderService recorder;
  final int sampleRate;
  final int numChannels;
  final Queue<Int16List> _queue = Queue();
  Timer? _timer;
  Completer<void>? _ready;

  GeminiHandler({
    required this.config,
    IAudioProcessor? processor,
    IBufferDrainer? drainer,
    WebSocketService? socket,
    AudioPlayerService? player,
    AudioRecorderService? recorder,
    this.sampleRate = 24000,
    this.numChannels = 1,
  }) : processor = processor ?? AudioProcessor(),
       drainer = drainer ?? BufferDrainer(frameSize: 24000 ~/ 50),
       socket = socket ?? WebSocketService(config.wsUrl),
       player = player ?? AudioPlayerService(),
       recorder = recorder ?? AudioRecorderService();

  Future<void> start() async {
    if (await Permission.microphone.request().isDenied) {
      throw Exception('Microphone denied');
    }

    await player.init(sampleRate: sampleRate, numChannels: numChannels);
    await recorder.init(sampleRate: sampleRate, numChannels: numChannels);

    _ready = Completer();
    socket.connect();

    recorder.audioStream?.listen((data) {
      final msg = processor.encode(data, sampleRate);
      socket.send(msg);
    });

    socket.messages.listen((msg) {
      if (msg.containsKey('setupComplete')) {
        _ready?.complete();
        return;
      }
      final parts =
          (msg['serverContent']?['modelTurn']?['parts'] as List?) ?? [];
      for (final p in parts) {
        final b64 = p['inlineData']?['data'] as String?;
        if (b64 != null) {
          final samples = processor.decode(b64);
          drainer.addSamples(samples);
          Int16List? frame;
          while ((frame = drainer.getFrame()) != null) {
            _queue.add(frame!);
          }
        }
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (_queue.isNotEmpty) player.playFrame(_queue.removeFirst());
    });

    await _ready!.future;
  }

  Future<void> stop() async {
    _timer?.cancel();
    socket.disconnect();
    await recorder.dispose();
    await player.dispose();
  }
}
