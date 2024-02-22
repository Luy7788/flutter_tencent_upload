#import "FlutterTencentUploadPlugin.h"
#import "TXUGCPublish.h"


@implementation FlutterTencentUploadPlugin {
    FlutterEventSink _eventSink;
    TXUGCPublish *_txUgcPublish;
    FlutterResult _result;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_tencent_upload" binaryMessenger:[registrar messenger]];
    FlutterTencentUploadPlugin* instance = [[FlutterTencentUploadPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *event = [FlutterEventChannel eventChannelWithName:@"flutter_tencent_upload_stream" binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"uploadVideo" isEqualToString:call.method]) {
        if (call.arguments != nil && [call.arguments isKindOfClass:NSDictionary.class]) {
            _result = result;
            @try {
                if (_eventSink != nil){
                    _eventSink(@(0));
                }
                NSString *token = call.arguments[@"token"];
                NSString *videoPath = call.arguments[@"videoPath"];
                NSString *coverPath = call.arguments[@"coverPath"];
                TXUGCPublish *publish = [[TXUGCPublish alloc] init];
                publish.delegate = self;
                TXPublishParam *param = [[TXPublishParam alloc] init];
                param.signature = token;
                param.videoPath = videoPath;//[videoPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                param.coverPath = coverPath;
                param.enableHTTPS = YES;
                [publish publishVideo:param];
            } @catch (NSException *exception) {
                NSLog(@"FlutterTencentUploadPlugin exception1: %@",exception);
                result(nil);
            }
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}
 

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}
    

/**
 * 短视频发布进度
 */
- (void)onPublishProgress:(NSInteger)uploadBytes totalBytes: (NSInteger)totalBytes {
    if (_eventSink != nil){
        double progress = uploadBytes*1.0/totalBytes;
//        NSLog(@"uploadBytes:%zd, totalBytes:%zd, progress:%f", uploadBytes, totalBytes, progress);
        _eventSink(@(progress));
    }
}

/**
 * 短视频发布完成
 */
- (void)onPublishComplete:(TXPublishResult*)result {
    @try {
        if (result.retCode == 0) {
            NSDictionary *data = @{
                @"code": @1,
                @"msg": @"上传成功",
                @"data": @{
                    @"id": result.videoId,
                    @"url": result.videoURL,
                    @"coverUrl": result.coverURL,
                }
            };
            _result(data);
        } else {
            NSDictionary *data = @{
                @"code": @(result.retCode),
                @"msg": result.descMsg,
                @"data": @{},
            };
            _result(data);
        }
    } @catch(NSException *exception) {
        NSLog(@"FlutterTencentUploadPlugin exception1: %@",exception);
        _result(nil);
    }
    
}

/**
 * 短视频发布事件通知
 */
- (void)onPublishEvent:(NSDictionary*)evt {
    ;
}


@end

