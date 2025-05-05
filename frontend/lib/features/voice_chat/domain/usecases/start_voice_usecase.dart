import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class StartVoiceUseCase {
  final VoiceChatRepository repository;
  StartVoiceUseCase(this.repository);

  Future<void> execute() => repository.startVoice();
}
