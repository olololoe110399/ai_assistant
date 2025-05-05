import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class AddAudioFrameVoiceUseCase {
  final VoiceChatRepository repository;
  AddAudioFrameVoiceUseCase(this.repository);

  void execute(AudioFrameState frame) => repository.addAudioFrame(frame);
}
