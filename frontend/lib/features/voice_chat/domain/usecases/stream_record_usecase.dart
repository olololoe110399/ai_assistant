import 'dart:typed_data';

import 'package:flutter_client/features/voice_chat/domain/domain.dart';

class StreamRecordUseCase {
  final VoiceChatRepository repository;
  StreamRecordUseCase(this.repository);

  Stream<Int16List> execute() => repository.outgoingStream;
}
