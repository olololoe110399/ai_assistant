import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/web.dart';

class AudioPlayerService {
  late FlutterSoundPlayer _player;

  Future<void> init({required int sampleRate, required int numChannels}) async {
    _player = FlutterSoundPlayer(logLevel: Level.off);
    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: numChannels,
      bufferSize: sampleRate ~/ 20,
      interleaved: false,
    );
  }

  void playFrame(Int16List frame) {
    _player.feedInt16FromStream([frame]);
  }

  Future<void> dispose() async {
    await _player.stopPlayer();
    await _player.closePlayer();
  }
}
