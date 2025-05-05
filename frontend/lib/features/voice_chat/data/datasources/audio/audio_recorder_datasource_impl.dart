import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_client/core/core.dart';
import 'package:flutter_client/features/features.dart';
import 'package:taudio/taudio.dart';

class AudioRecorderDataSourceImpl implements AudioRecorderDataSource {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final int sampleRate;
  final int numChannels;
  final int frameSize;
  late final int frameDuration;
  StreamController<List<Int16List>> recordingDataInt16 =
      StreamController<List<Int16List>>.broadcast();
  StreamSubscription? _recorderDbLevelSubscription;
  StreamController<double> recordingDbLevelData =
      StreamController<double>.broadcast();

  AudioRecorderDataSourceImpl({
    this.sampleRate = VoiceStreamConfig.sampleRate,
    this.numChannels = VoiceStreamConfig.channels,
    this.frameSize = VoiceStreamConfig.frameSize,
  }) : frameDuration = (frameSize / sampleRate * 1000).round();

  @override
  Stream<double> get onDbLevelChange => recordingDbLevelData.stream;

  @override
  Stream<List<Int16List>> get outgoing => recordingDataInt16.stream;

  @override
  Future<void> init() async {
    await PermissionHandler.requestPermission();
    if (!await PermissionHandler.isPermissionGranted()) {
      throw Exception('Microphone permission not granted');
    }
    await _recorder.openRecorder();
    _recorderDbLevelSubscription = _recorder.onProgress!.listen((e) {
      recordingDbLevelData.add(e.decibels as double);
    });
    await _recorder.setSubscriptionDuration(
      Duration(milliseconds: frameDuration),
    );
  }

  @override
  Future<void> start() async {
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: numChannels,
      audioSource: AudioSource.microphone,
      toStreamInt16: recordingDataInt16.sink,
      enableEchoCancellation: true,
      enableNoiseSuppression: true,
      enableVoiceProcessing: true,
    );
  }

  @override
  Future<void> stop() async {
    await _recorder.stopRecorder();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _recorderDbLevelSubscription?.cancel();
    _recorderDbLevelSubscription = null;
    await _recorder.closeRecorder();
    await recordingDataInt16.close();
    await recordingDbLevelData.close();
  }

  @override
  bool get isRecording => _recorder.isRecording;

  @override
  bool get isPaused => _recorder.isPaused;

  @override
  Future<void> resumeRecorder() async {
    if (_recorder.isStopped || _recorder.isRecording) {
      return;
    }
    try {
      await _recorder.resumeRecorder();
      assert(_recorder.isRecording);
    } on Exception catch (err) {
      _recorder.logger.e('error: $err');
    }
  }

  @override
  Future<void> pauseRecorder() async {
    if (_recorder.isStopped || _recorder.isPaused) {
      return;
    }
    try {
      await _recorder.pauseRecorder();
      assert(_recorder.isPaused);
    } on Exception catch (err) {
      _recorder.logger.e('error: $err');
    }
  }
}
