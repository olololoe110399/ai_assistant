import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_client/rtc-sdk/agora-manager/agora_manager.dart';

mixin UiHelper {
  late AgoraManager _agoraManager;
  late VoidCallback _setStateCallback;
  int mainViewUid = -1;

  void initializeUiHelper(
    AgoraManager agoraManager,
    VoidCallback setStateCallback,
  ) {
    _agoraManager = agoraManager;
    _setStateCallback = setStateCallback;
  }

  Future<void> leave() async {
    await _agoraManager.leave();
    mainViewUid = -1;
  }

  Widget textContainer(String text, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(border: Border.all()),
      margin: const EdgeInsets.only(bottom: 5),
      child: Center(child: Text(text, textAlign: TextAlign.center)),
    );
  }

  void onUserOffline(int remoteUid) {
    if (mainViewUid == remoteUid) {
      mainViewUid = -1;
    }
    _setStateCallback();
  }

  void onUserJoined(int remoteUid) {
    mainViewUid = remoteUid;
    _setStateCallback();
  }
}
