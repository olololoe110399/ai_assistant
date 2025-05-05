import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class StopVoiceUseCase {
  final VoiceChatRepository repository;
  StopVoiceUseCase(this.repository);

  Future<void> execute() => repository.stopVoice();
}
