import 'dart:convert';
import 'dart:typed_data';

typedef JsonMap = Map<String, dynamic>;

class AudioProcessor {
  static JsonMap encodeAudio(Int16List data, {required int sampleRate}) {
    final b64 = base64Encode(Uint8List.view(data.buffer));
    return {
      'realtimeInput': {
        'mediaChunks': [
          {'mimeType': 'audio/pcm;rate=$sampleRate', 'data': b64},
        ],
      },
    };
  }

  static Int16List decodeAudio(String b64) {
    final bytes = base64Decode(b64);
    return Int16List.view(bytes.buffer);
  }
}
