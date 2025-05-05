import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class DisposeVoiceUseCase {
  final VoiceChatRepository repository;
  DisposeVoiceUseCase(this.repository);

  Future<void> execute() => repository.disposeVoice();
}
