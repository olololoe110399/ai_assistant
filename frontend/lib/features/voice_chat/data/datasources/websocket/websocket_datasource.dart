import 'package:flutter_client/core/utils/audio_processor.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';

abstract class WebSocketDataSource {
  Stream<AudioFrameState> get incoming;

  void send(JsonMap json);

  Future<void> connect();

  Future<void> dispose();
}
