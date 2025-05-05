import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<PermissionStatus> checkPermission() async {
    return Permission.microphone.status;
  }

  static Future<void> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      // Handle the case when the user denies the permission
      // You can show a dialog or a snackbar to inform the user
    } else if (status.isPermanentlyDenied) {
      // Handle the case when the user permanently denies the permission
      // You can open the app settings to let the user enable it
      await openAppSettings();
    }
  }

  static Future<bool> isPermissionGranted() async {
    final status = await checkPermission();
    return status.isGranted;
  }

  static Future<void> configure() async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
  }
}
