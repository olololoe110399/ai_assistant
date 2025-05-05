import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_client/core/core.dart';
import 'package:flutter_client/features/voice_chat/data/data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDataSourceImpl implements WebSocketDataSource {
  final String url;
  late WebSocketChannel _channel;
  late StreamController<AudioFrameState> _incomingController;

  WebSocketDataSourceImpl({required this.url});

  @override
  Stream<AudioFrameState> get incoming => _incomingController.stream;

  @override
  Future<void> connect() async {
    _incomingController = StreamController<AudioFrameState>.broadcast();
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen(
      (message) {
        try {
          final utf8Msg = message is String ? message : utf8.decode(message);
          final jsonMsg = jsonDecode(utf8Msg) as JsonMap;

          if (jsonMsg['serverContent'] != null &&
              jsonMsg['serverContent']?['turnComplete'] == true) {
            _incomingController.add(AudioFrameStateCompleted());
            return;
          }
          if (jsonMsg.containsKey('setupComplete')) {
            _incomingController.add(AudioFrameStateInitial());
            return;
          }
          if (jsonMsg.containsKey('tool_response')) {
            final functionResponses =
                jsonMsg['tool_response']['function_responses'];
            debugPrint('Tool response: $functionResponses');
            if ((functionResponses ?? []).isEmpty ||
                functionResponses[0]?['response']?['result'] == null) {
              return;
            }
            _incomingController.add(
              AudioFrameStateMapTools(
                MapTools.fromJson(functionResponses[0]['response']['result']),
              ),
            );
            return;
          }
          final parts = jsonMsg['serverContent']?['modelTurn']?['parts'] ?? [];
          for (final part in parts) {
            final b64 = part['inlineData']?['data'];
            if (b64 != null && b64 is String) {
              _incomingController.add(
                AudioFrameStateLoaded(AudioProcessor.decodeAudio(b64)),
              );
            }
          }
        } catch (e) {
          _incomingController.addError(e);
        }
      },
      onError: (error) {
        _incomingController.addError(error);
      },
      onDone: () {
        _incomingController.close();
      },
    );
  }

  @override
  void send(JsonMap json) {
    if (_channel.closeCode == null) {
      _channel.sink.add(jsonEncode(json));
    }
  }

  @override
  Future<void> dispose() async {
    await _channel.sink.close();
    await _incomingController.close();
  }
}
