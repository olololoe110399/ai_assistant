import 'dart:typed_data';

abstract class AudioRecorderDataSource {
  bool get isRecording;
  bool get isPaused;

  Stream<double> get onDbLevelChange;

  Stream<List<Int16List>> get outgoing;

  Future<void> init();

  Future<void> start();

  Future<void> resumeRecorder();

  Future<void> pauseRecorder();

  Future<void> stop();

  Future<void> dispose();
}
