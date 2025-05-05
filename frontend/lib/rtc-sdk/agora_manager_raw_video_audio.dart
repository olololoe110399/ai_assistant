import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_client/rtc-sdk/authentication-workflow/agora_manager_authentication.dart';
import 'package:flutter_client/rtc-sdk/agora-manager/agora_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraManagerRawVideoAudio extends AgoraManagerAuthentication {
  late AudioFrameObserver audioFrameObserver;

  AgoraManagerRawVideoAudio({
    required super.currentProduct,
    required super.messageCallback,
    required super.eventCallback,
  });

  static Future<AgoraManagerRawVideoAudio> create({
    required ProductName currentProduct,
    required Function(String message) messageCallback,
    required Function(String eventName, Map<String, dynamic> eventArgs)
        eventCallback,
  }) async {
    final manager = AgoraManagerRawVideoAudio(
      currentProduct: currentProduct,
      messageCallback: messageCallback,
      eventCallback: eventCallback,
    );

    await manager.initialize();
    return manager;
  }

  @override
  Future<void> setupAgoraEngine() async {
    await [Permission.microphone].request();
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine!.initialize(RtcEngineContext(appId: appId));

    if (currentProduct != ProductName.voiceCalling) {
      await agoraEngine!.enableVideo();
    }
    agoraEngine!.registerEventHandler(getEventHandler());
  }
}
