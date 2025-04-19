import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  WebSocketService(this.url);

  Stream<Map<String, dynamic>> get messages => _controller.stream;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel!.stream.listen(
      (raw) {
        final text = raw is List<int> ? utf8.decode(raw) : raw;
        final msg = jsonDecode(text) as Map<String, dynamic>;
        _controller.add(msg);
      },
      onError: (e) => _controller.addError(e),
      onDone: () => disconnect(),
    );
  }

  void send(Map<String, dynamic> msg) {
    _channel?.sink.add(jsonEncode(msg));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
