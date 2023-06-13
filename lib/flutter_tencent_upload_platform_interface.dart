import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_tencent_upload_method_channel.dart';

abstract class FlutterTencentUploadPlatform extends PlatformInterface {
  /// Constructs a FlutterTencentUploadPlatform.
  FlutterTencentUploadPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTencentUploadPlatform _instance = MethodChannelFlutterTencentUpload();

  /// The default instance of [FlutterTencentUploadPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTencentUpload].
  static FlutterTencentUploadPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTencentUploadPlatform] when
  /// they register themselves.
  static set instance(FlutterTencentUploadPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
