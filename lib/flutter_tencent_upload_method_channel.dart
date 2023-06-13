import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_tencent_upload_platform_interface.dart';

/// An implementation of [FlutterTencentUploadPlatform] that uses method channels.
class MethodChannelFlutterTencentUpload extends FlutterTencentUploadPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_tencent_upload');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
