import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class InitialVoiceUseCase {
  final VoiceChatRepository repository;
  InitialVoiceUseCase(this.repository);

  Future<void> execute() => repository.initialVoice();
}
