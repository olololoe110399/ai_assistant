import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../application/gemini_handler.dart';

class VoiceChatViewModel extends ChangeNotifier {
  final GeminiHandler _handler = GetIt.instance<GeminiHandler>();
  bool _running = false;
  String _status = 'Stopped';

  bool get running => _running;
  String get status => _status;

  Future<void> toggle() async {
    if (_running) {
      _status = 'Stopping…';
      notifyListeners();
      await _handler.stop();
      _running = false;
      _status = 'Stopped';
    } else {
      _status = 'Connecting…';
      notifyListeners();
      try {
        await _handler.start();
        _running = true;
        _status = 'Connected';
      } catch (e) {
        _status = 'Error: $e';
      }
    }
    notifyListeners();
  }
}
