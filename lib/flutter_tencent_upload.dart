
import 'flutter_tencent_upload_platform_interface.dart';

class FlutterTencentUpload {
  Future<String?> getPlatformVersion() {
    return FlutterTencentUploadPlatform.instance.getPlatformVersion();
  }
}
