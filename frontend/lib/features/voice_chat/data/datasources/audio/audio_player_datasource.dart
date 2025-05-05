import 'package:flutter/material.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';

abstract class AudioPlayerDataSource {
  void addAudioFrame(AudioFrameState frame);

  Future<void> init();

  Future<void> start();

  Future<void> pauseResumePlayer();

  Future<void> stop();

  Future<void> dispose();

  ValueNotifier<bool> get isPlaying;
}
