import 'dart:typed_data';

abstract class IAudioProcessor {
  Map<String, dynamic> encode(Uint8List pcmData, int sampleRate);
  Int16List decode(String b64);
}

abstract class IBufferDrainer {
  void addSamples(Int16List samples);
  Int16List? getFrame();
}
