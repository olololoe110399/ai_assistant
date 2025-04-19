import 'dart:convert';
import 'dart:typed_data';
import 'interfaces.dart';

class AudioProcessor implements IAudioProcessor {
  @override
  Map<String, dynamic> encode(Uint8List pcmData, int sampleRate) {
    final b64 = base64Encode(pcmData);
    return {
      'realtimeInput': {
        'mediaChunks': [
          {'mimeType': 'audio/pcm;rate=$sampleRate', 'data': b64},
        ],
      },
    };
  }

  @override
  Int16List decode(String b64) {
    final bytes = base64Decode(b64);
    return bytes.buffer.asInt16List(
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 2,
    );
  }
}
