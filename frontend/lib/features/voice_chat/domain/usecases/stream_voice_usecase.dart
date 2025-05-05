import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class StreamVoiceUseCase {
  final VoiceChatRepository repository;
  StreamVoiceUseCase(this.repository);

  Stream<AudioFrameState> execute() {
    return repository.receiveFrames();
  }
}
