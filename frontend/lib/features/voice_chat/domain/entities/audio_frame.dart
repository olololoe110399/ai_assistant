import 'dart:typed_data';

class MapTools {
  final String url;
  final int width;
  final int height;
  final String format;
  final int quality;
  final String type;

  const MapTools({
    required this.url,
    required this.width,
    required this.height,
    required this.format,
    required this.quality,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
      'format': format,
      'quality': quality,
      'type': type,
    };
  }

  factory MapTools.fromJson(Map<String, dynamic> json) {
    return MapTools(
      url: json['url'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      format: json['format'] as String,
      quality: json['quality'] as int,
      type: json['type'] as String,
    );
  }
}

sealed class AudioFrameState {
  const AudioFrameState();
}

class AudioFrameStateInitial extends AudioFrameState {
  const AudioFrameStateInitial();
}

class AudioFrameStateLoaded extends AudioFrameState {
  final Int16List samples;
  const AudioFrameStateLoaded(this.samples);
}

class AudioFrameStateMapTools extends AudioFrameState {
  final MapTools map;
  const AudioFrameStateMapTools(this.map);
}

class AudioFrameStateCompleted extends AudioFrameState {
  const AudioFrameStateCompleted();
}
