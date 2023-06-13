import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tencent_upload/flutter_tencent_upload.dart';
import 'package:flutter_tencent_upload/flutter_tencent_upload_platform_interface.dart';
import 'package:flutter_tencent_upload/flutter_tencent_upload_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTencentUploadPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTencentUploadPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterTencentUploadPlatform initialPlatform = FlutterTencentUploadPlatform.instance;

  test('$MethodChannelFlutterTencentUpload is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTencentUpload>());
  });

  test('getPlatformVersion', () async {
    FlutterTencentUpload flutterTencentUploadPlugin = FlutterTencentUpload();
    MockFlutterTencentUploadPlatform fakePlatform = MockFlutterTencentUploadPlatform();
    FlutterTencentUploadPlatform.instance = fakePlatform;

    expect(await flutterTencentUploadPlugin.getPlatformVersion(), '42');
  });
}
