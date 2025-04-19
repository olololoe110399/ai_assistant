import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/web.dart';

class AudioRecorderService {
  late FlutterSoundRecorder _recorder;
  StreamController<Uint8List>? _controller;

  Stream<Uint8List>? get audioStream => _controller?.stream;

  Future<void> init({required int sampleRate, required int numChannels}) async {
    _recorder = FlutterSoundRecorder(logLevel: Level.off);
    await _recorder.openRecorder();
    _controller = StreamController<Uint8List>();
    await _recorder.startRecorder(
      toStream: _controller,
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: numChannels,
      bufferSize: sampleRate ~/ 20,
    );
  }

  Future<void> dispose() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    await _controller?.close();
  }
}
