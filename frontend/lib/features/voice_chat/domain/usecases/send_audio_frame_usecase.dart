import 'dart:typed_data';

import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class SendAudioFrameVoiceUseCase {
  final VoiceChatRepository repository;
  SendAudioFrameVoiceUseCase(this.repository);

  void execute(Int16List frame) => repository.sendFrame(frame);
}
