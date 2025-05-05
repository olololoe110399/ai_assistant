import 'dart:typed_data';

import 'package:flutter_client/features/voice_chat/data/data.dart';

abstract class VoiceChatRepository {
  Future<void> initialVoice();
  Future<void> startVoice();
  Future<void> stopVoice();
  Future<void> disposeVoice();
  Future<void> sendFrame(Int16List frame);
  Stream<AudioFrameState> receiveFrames();
  Stream<Int16List> get outgoingStream;
  void addAudioFrame(AudioFrameState frame);
}
