import 'dart:typed_data';

import 'package:flutter_client/core/core.dart';
export 'package:flutter_client/features/voice_chat/domain/domain.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';

class VoiceChatRepositoryImpl implements VoiceChatRepository {
  final AudioPlayerDataSource player;
  final WebSocketDataSource socket;
  final AudioRecorderDataSource recorder;

  VoiceChatRepositoryImpl({
    required this.player,
    required this.socket,
    required this.recorder,
  });

  @override
  Future<void> initialVoice() async {
    await PermissionHandler.configure();
    await player.init();
    await recorder.init();
  }

  @override
  Future<void> sendFrame(Int16List frame) async {
    final msg = AudioProcessor.encodeAudio(
      frame,
      sampleRate: VoiceStreamConfig.sampleRate,
    );
    socket.send(msg);
  }

  @override
  Stream<AudioFrameState> receiveFrames() => socket.incoming;

  @override
  Future<void> disposeVoice() async {
    await stopVoice();
    await player.dispose();
    await recorder.dispose();
    await socket.dispose();
  }

  @override
  Future<void> startVoice() async {
    await socket.connect();
    await player.start();
    await recorder.start();
    player.isPlaying.addListener(listenToAudioStream);
  }

  void listenToAudioStream() {
    if (player.isPlaying.value) {
      if (recorder.isRecording) {
        recorder.pauseRecorder();
      }
    } else {
      if (recorder.isPaused) {
        recorder.resumeRecorder();
      }
    }
  }

  @override
  Future<void> stopVoice() async {
    await recorder.stop();
    await player.stop();
    await socket.dispose();
    player.isPlaying.removeListener(listenToAudioStream);
  }

  @override
  void addAudioFrame(AudioFrameState frame) => player.addAudioFrame(frame);

  @override
  Stream<Int16List> get outgoingStream => recorder.outgoing.map((e) => e.first);
}
