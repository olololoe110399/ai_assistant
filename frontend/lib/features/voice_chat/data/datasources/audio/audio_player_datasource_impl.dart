import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/core/core.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';
import 'package:taudio/taudio.dart';

class AudioPlayerDataSourceImpl implements AudioPlayerDataSource {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final int sampleRate;
  final int numChannels;
  final int frameSize;
  late final int frameDuration;
  final StreamController<AudioFrameState> _audioStreamController =
      StreamController<AudioFrameState>.broadcast();
  StreamQueue<AudioFrameState>? _streamQueue;
  Timer? _timer;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);

  @override
  ValueNotifier<bool> get isPlaying => _isPlaying;

  AudioPlayerDataSourceImpl({
    this.sampleRate = VoiceStreamConfig.sampleRate,
    this.numChannels = VoiceStreamConfig.channels,
    this.frameSize = VoiceStreamConfig.frameSize,
  }) : frameDuration = (frameSize / sampleRate * 1000).round();

  @override
  Future<void> init() async {
    await _player.openPlayer();
    await _player.setSubscriptionDuration(
      Duration(milliseconds: frameDuration),
    );
  }

  @override
  Future<void> start() async {
    await _streamQueue?.cancel(immediate: true);
    _streamQueue = StreamQueue<AudioFrameState>(_audioStreamController.stream);
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: numChannels,
      interleaved: false,
      bufferSize: frameSize * 2,
    );
    playWithQueue();
  }

  Future<void> playWithQueue() async {
    if (_streamQueue == null) {
      return;
    }
    while (true) {
      if (!await _streamQueue!.hasNext) break;
      final frame = await _streamQueue!.next;
      switch (frame) {
        case AudioFrameStateInitial():
        case AudioFrameStateMapTools():
          break;
        case AudioFrameStateLoaded(samples: var samples):
          if (!_isPlaying.value) {
            _isPlaying.value = true;
          }
          _timer?.cancel();
          await _player.feedInt16FromStream([samples]);
          break;
        case AudioFrameStateCompleted():
          _timer = Timer(const Duration(milliseconds: 500), () {
            _isPlaying.value = false;
          });
          break;
      }
    }
  }

  @override
  void addAudioFrame(AudioFrameState frame) {
    if (_player.isStopped) {
      return;
    }
    _audioStreamController.add(frame);
  }

  @override
  Future<void> stop() async {
    await _player.stopPlayer();
    _isPlaying.value = false;
  }

  @override
  Future<void> dispose() async {
    await _streamQueue?.cancel(immediate: true);
    _streamQueue = null;
    _audioStreamController.close();
    await stop();
    await _player.closePlayer();
  }

  @override
  Future<void> pauseResumePlayer() async {
    if (_player.isStopped) {
      return;
    }
    try {
      if (_player.isPaused) {
        await _player.resumePlayer();
      } else {
        await _player.pausePlayer();
        assert(_player.isPaused);
      }
    } catch (e) {
      debugPrint('Error pausing/resuming player: $e');
    }
  }
}
