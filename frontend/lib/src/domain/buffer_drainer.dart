import 'dart:typed_data';
import 'interfaces.dart';

class BufferDrainer implements IBufferDrainer {
  final int frameSize;
  Int16List _buffer = Int16List(0);

  BufferDrainer({required this.frameSize});

  @override
  void addSamples(Int16List samples) {
    final combined =
        Int16List(_buffer.length + samples.length)
          ..setRange(0, _buffer.length, _buffer)
          ..setRange(_buffer.length, _buffer.length + samples.length, samples);
    _buffer = combined;
  }

  @override
  Int16List? getFrame() {
    if (_buffer.length >= frameSize) {
      final frame = _buffer.sublist(0, frameSize);
      _buffer = _buffer.sublist(frameSize);
      return frame;
    }
    return null;
  }
}
