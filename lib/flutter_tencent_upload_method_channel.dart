import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// An implementation of [FlutterTencentUploadPlatform] that uses method channels.
class MethodChannelFlutterTencentUpload extends PlatformInterface {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_tencent_upload');

  final EventChannel eventChannel = const EventChannel('flutter_tencent_upload_stream');

  MethodChannelFlutterTencentUpload() : super(token: _token);

  static final Object _token = Object();

  static final MethodChannelFlutterTencentUpload _instance =
      MethodChannelFlutterTencentUpload();

  /// The default instance of [FlutterTencentUploadPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTencentUpload].
  static MethodChannelFlutterTencentUpload get instance => _instance;

  Future init() async {
    await methodChannel.invokeMethod<String>('init');
  }

  void dispose() {
    _subscription.cancel();
  }

  late StreamSubscription _subscription;
  UploadProgressCallback? progress;

  /// 获取上传进度流
  void onProgressResult() {
    _subscription = eventChannel.receiveBroadcastStream().listen((dynamic event) {
      debugPrint("eventChannel :$event");
      if (event is int || event is double) {
        progress?.call(event * 1.0);
      }
    });
  }

  ///上传视频
  ///token 签名
  ///videoPath 视频路径
  ///coverPath 封面路径
  ///progress 上传进度
  ///sucCallback 成功回调
  ///failCallback 失败回调
  Future<Map?> uploadVideo(
    String token,
    String videoPath, {
    String coverPath = "",
    UploadProgressCallback? progress,
    UploadSucCallback? sucCallback,
    UploadFailCallback? failCallback,
  }) async {
    this.progress = progress;
    var arguments = {};
    arguments['token'] = token;
    arguments['videoPath'] = videoPath;
    arguments['coverPath'] = coverPath;
    Map? result;
    try {
      onProgressResult();
      result = await methodChannel.invokeMethod('uploadVideo', arguments);
    } catch (e) {
      debugPrint("methodChannel.invokeMethod('uploadVideo', arguments) e: $e");
      failCallback?.call(-1, "文件上传失败");
      return null;
    }
    if (result != null && (sucCallback != null || failCallback != null)) {
      int code = result["code"];
      String msg = result["msg"];
      Map? data = result["data"];
      if (code == 1 && data != null) {
        progress?.call(1);
        String id = data["id"];
        String url = data["url"];
        String coverUrl = data["coverUrl"];
        sucCallback?.call(id ,url ,coverUrl);
      } else {
        failCallback?.call(code, msg);
      }
    } else {
      failCallback?.call(-1, "文件上传失败！");
    }
    progress = null;
    return result;
  }
}

typedef UploadProgressCallback = void Function(double percent);

typedef UploadSucCallback = void Function(String id , String url, String coverUrl);

typedef UploadFailCallback = void Function(int code, String msg);
