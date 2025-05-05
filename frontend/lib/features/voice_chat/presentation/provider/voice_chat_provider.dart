import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_client/core/core.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';
import 'package:flutter_client/features/voice_chat/presentation/widgets/waveform.dart';

class VoiceChatProvider extends ChangeNotifier {
  late final StreamVoiceUseCase _useCase;
  late final InitialVoiceUseCase _initialUseCase;
  late final StartVoiceUseCase _startUseCase;
  late final StopVoiceUseCase _stopUseCase;
  late final DisposeVoiceUseCase _disposeUseCase;
  late final AddAudioFrameVoiceUseCase _addAudioFrameUseCase;
  late final SendAudioFrameVoiceUseCase _sendAudioFrameUseCase;
  late final StreamRecordUseCase _streamRecordUseCase;
  late final VoiceChatRepository _repo;
  bool isStreaming = false;
  MapTools? mapTools;
  StreamSubscription<AudioFrameState>? _subscription;
  StreamSubscription<Int16List>? _subscriptionRecord;
  final StreamController<Int16List> _streamController =
      StreamController<Int16List>.broadcast();

  double calculateRMSAmplitude(Int16List samples) {
    if (samples.isEmpty) return 0;
    double sum = 0;
    for (final s in samples) {
      sum += s * s;
    }
    return sqrt(sum / samples.length);
  }

  Stream<Amplitude> get stream => _streamController.stream.map((frame) {
    double normalized = calculateRMSAmplitude(frame) / 32768.0;
    final scaled = (normalized * 20).clamp(0.0, 1.0);
    return Amplitude(current: scaled);
  });

  VoiceChatProvider() {
    _repo = VoiceChatRepositoryImpl(
      player: AudioPlayerDataSourceImpl(),
      socket: WebSocketDataSourceImpl(url: VoiceStreamConfig.wsUri),
      recorder: AudioRecorderDataSourceImpl(),
    );
    _useCase = StreamVoiceUseCase(_repo);
    _initialUseCase = InitialVoiceUseCase(_repo);
    _startUseCase = StartVoiceUseCase(_repo);
    _stopUseCase = StopVoiceUseCase(_repo);
    _disposeUseCase = DisposeVoiceUseCase(_repo);
    _addAudioFrameUseCase = AddAudioFrameVoiceUseCase(_repo);
    _sendAudioFrameUseCase = SendAudioFrameVoiceUseCase(_repo);
    _streamRecordUseCase = StreamRecordUseCase(_repo);
  }

  Future<void> init() => _initialUseCase.execute();

  Future<void> start() async {
    await _startUseCase.execute();
    _subscriptionRecord = _streamRecordUseCase.execute().listen((e) {
      _sendAudioFrameUseCase.execute(e);
      _streamController.add(e);
    });
    _subscription = _useCase.execute().listen((e) {
      _addAudioFrameUseCase.execute(e);
      if (e is AudioFrameStateMapTools) {
        mapTools = e.map;
        notifyListeners();
      }
    });
    isStreaming = true;
    notifyListeners();
  }

  Future<void> stop() async {
    await _stopUseCase.execute();
    _subscription?.cancel();
    _subscriptionRecord?.cancel();
    _subscriptionRecord = null;
    _subscription = null;
    isStreaming = false;
    notifyListeners();
  }

  @override
  void dispose() async {
    if (isStreaming) {
      await stop();
    }
    await _streamController.close();
    await _disposeUseCase.execute();
    super.dispose();
  }
}
