import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_client/rtc-sdk/agora-manager/agora_manager.dart';
import 'package:flutter_client/rtc-sdk/agora-manager/ui_helper.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'agora_manager_raw_video_audio.dart';

class RawVideoAudioScreen extends StatefulWidget {
  final ProductName selectedProduct;
  const RawVideoAudioScreen({super.key, required this.selectedProduct});

  @override
  RawVideoAudioScreenState createState() => RawVideoAudioScreenState();
}

class RawVideoAudioScreenState extends State<RawVideoAudioScreen>
    with UiHelper {
  late AgoraManagerRawVideoAudio agoraManager;
  bool isAgoraManagerInitialized = false;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Build UI
  @override
  Widget build(BuildContext context) {
    if (!isAgoraManagerInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Raw audio processing')),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed:
                    agoraManager.isJoined ? () => {leave()} : () => {join()},
                child: Text(agoraManager.isJoined ? "Leave" : "Join"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    agoraManager = await AgoraManagerRawVideoAudio.create(
      currentProduct: widget.selectedProduct,
      messageCallback: showMessage,
      eventCallback: eventCallback,
    );

    setState(() {
      initializeUiHelper(agoraManager, setStateCallback);
      isAgoraManagerInitialized = true;
    });
  }

  Future<void> join() async {
    await agoraManager.joinChannelWithToken();
  }

  // Release the resources when you leave
  @override
  Future<void> dispose() async {
    agoraManager.dispose();
    super.dispose();
  }

  void eventCallback(String eventName, Map<String, dynamic> eventArgs) {
    // Handle the event based on the event name and named arguments
    switch (eventName) {
      case 'onConnectionStateChanged':
        // Connection state changed
        if (eventArgs["reason"] ==
            ConnectionChangedReasonType.connectionChangedLeaveChannel) {
          setState(() {});
        }
        break;

      case 'onJoinChannelSuccess':
        setState(() {});
        break;

      case 'onUserJoined':
        onUserJoined(eventArgs["remoteUid"]);
        break;

      case 'onUserOffline':
        onUserOffline(eventArgs["remoteUid"]);
        break;
    }
  }

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void setStateCallback() {
    setState(() {});
  }
}
