import 'flutter_tencent_upload_method_channel.dart';

class TencentUploadManager {
  // static void init() {
  //   MethodChannelFlutterTencentUpload.instance.init();
  // }

  ///上传视频
  ///token 签名
  ///videoPath 视频路径
  ///coverPath 封面路径
  ///progress 上传进度
  ///sucCallback 成功回调
  ///failCallback 失败回调
  static Future<Map?> uploadVideo(
    String token,
    String videoPath, {
    String coverPath = "",
    UploadProgressCallback? progress,
    UploadSucCallback? sucCallback,
    UploadFailCallback? failCallback,
  }) {
    return MethodChannelFlutterTencentUpload.instance.uploadVideo(
      token,
      videoPath,
      coverPath: coverPath,
      progress: progress,
      sucCallback: sucCallback,
      failCallback: failCallback,
    );
  }
}
