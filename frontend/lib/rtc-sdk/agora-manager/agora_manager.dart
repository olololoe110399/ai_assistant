import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProductName {
  videoCalling,
  voiceCalling,
  interactiveLiveStreaming,
  broadcastStreaming,
}

class AgoraManager {
  ProductName currentProduct = ProductName.videoCalling;
  late Map<String, dynamic> config;
  int localUid = -1;
  String appId = "", channelName = "";
  List<int> remoteUuids = [];
  bool isJoined = false;
  RtcEngine? agoraEngine; // Agora engine instance

  Function(String message) messageCallback;
  Function(String eventName, Map<String, dynamic> eventArgs) eventCallback;

  AgoraManager.protectedConstructor({
    required this.currentProduct,
    required this.messageCallback,
    required this.eventCallback,
  });

  static Future<AgoraManager> create({
    required ProductName currentProduct,
    required Function(String message) messageCallback,
    required Function(String eventName, Map<String, dynamic> eventArgs)
    eventCallback,
  }) async {
    final manager = AgoraManager.protectedConstructor(
      currentProduct: currentProduct,
      messageCallback: messageCallback,
      eventCallback: eventCallback,
    );

    await manager.initialize();
    return manager;
  }

  Future<void> initialize() async {
    try {
      config = {
        "uid": 0,
        "appId": "bb1c652d462b4da2b7f74108ed3d4a27",
        "channelName": "test",
        "rtcToken": "",
        "proxyUrl": "<---- Your Proxy Server URL ---->",
        "serverUrl": "",
        "tokenExpiryTime": "300",
        "encryptionKey":
            "55f9ae116e715fbde00c12d86a00e4199990a182e80b4e66148e81d66a43d3c2",
        "salt": "y2X4ayYze+gFmNlhi6Qx5pjHDF+FNc+IghhxmM6vhvI=",
        "sampleMediaUrl":
            "https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
        "destinationChannelName": "destiny",
        "destinationChannelUid": 100,
        "destinationChannelToken": "",
        "sourceChannelToken": "",
        "secondChannelName": "demo2",
        "secondChannelUid": 101,
        "secondChannelToken": "",
      };
      appId = config["appId"];
      channelName = config["channelName"];
      localUid = config["uid"];
    } catch (e) {
      messageCallback(e.toString());
    }
  }

  RtcEngineEventHandler getEventHandler() {
    return RtcEngineEventHandler(
      // Occurs when the network connection state changes
      onConnectionStateChanged: (
        RtcConnection connection,
        ConnectionStateType state,
        ConnectionChangedReasonType reason,
      ) {
        if (reason ==
            ConnectionChangedReasonType.connectionChangedLeaveChannel) {
          remoteUuids.clear();
          isJoined = false;
        }
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["state"] = state;
        eventArgs["reason"] = reason;
        eventCallback("onConnectionStateChanged", eventArgs);
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        isJoined = true;
        messageCallback(
          "Local user uid:${connection.localUid} joined the channel",
        );
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["elapsed"] = elapsed;
        eventCallback("onJoinChannelSuccess", eventArgs);
      },
      // Occurs when a remote user joins the channel
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteUuids.add(remoteUid);
        messageCallback("Remote user uid:$remoteUid joined the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["elapsed"] = elapsed;
        eventCallback("onUserJoined", eventArgs);
      },
      // Occurs when a remote user leaves the channel
      onUserOffline: (
        RtcConnection connection,
        int remoteUid,
        UserOfflineReasonType reason,
      ) {
        remoteUuids.remove(remoteUid);
        messageCallback("Remote user uid:$remoteUid left the channel");
        // Notify the UI
        Map<String, dynamic> eventArgs = {};
        eventArgs["connection"] = connection;
        eventArgs["remoteUid"] = remoteUid;
        eventArgs["reason"] = reason;
        eventCallback("onUserOffline", eventArgs);
      },
    );
  }

  Future<void> setupAgoraEngine() async {
    await [Permission.microphone].request();

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine!.initialize(RtcEngineContext(appId: appId));

    agoraEngine!.registerEventHandler(getEventHandler());
  }

  Future<void> join({
    String channelName = '',
    String token = '',
    int uid = -1,
    ClientRoleType clientRole = ClientRoleType.clientRoleAudience,
  }) async {
    channelName = (channelName.isEmpty) ? this.channelName : channelName;
    token = (token.isEmpty) ? config['rtcToken'] : token;
    uid = (uid == -1) ? localUid : uid;

    if (agoraEngine == null) await setupAgoraEngine();

    await agoraEngine!.startPreview();

    ChannelMediaOptions options = ChannelMediaOptions(
      clientRoleType: clientRole,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine!.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  Future<void> leave() async {
    remoteUuids.clear();

    if (agoraEngine != null) {
      await agoraEngine!.leaveChannel();
    }
    isJoined = false;

    destroyAgoraEngine();
  }

  void destroyAgoraEngine() {
    if (agoraEngine != null) {
      agoraEngine!.release();
      agoraEngine = null;
    }
  }

  Future<void> dispose() async {
    if (isJoined) {
      await leave();
    }
    destroyAgoraEngine();
  }
}
