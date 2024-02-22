package com.example.flutter_tencent_upload;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.flutter_tencent_upload.videoupload.TXUGCPublish;
import com.example.flutter_tencent_upload.videoupload.TXUGCPublishTypeDef;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterTencentUploadPlugin
 */
public class FlutterTencentUploadPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private static Context mContext;
    private EventChannel eventChannel;
    public static EventChannel.EventSink mEventSink = null;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        if (null == mContext) {
            mContext = flutterPluginBinding.getApplicationContext();
        }
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_tencent_upload");
        channel.setMethodCallHandler(this);
        /**
         * 回调监听通道
         */
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_tencent_upload_stream");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("uploadVideo")) {
            Map<String, String> videoInfo = (Map<String, String>) call.arguments;
            if (videoInfo != null) {
                if (mEventSink != null) {
                    mEventSink.success(0.0);
                }
                String token = videoInfo.get("token");
                String filePath = videoInfo.get("videoPath");
                String coverPath = videoInfo.get("coverPath");
                uploadVideo(mContext, token, filePath, coverPath, new OnLiteUploadListener() {
                    @Override
                    public void onSuc(String id, String url, String coverUrl) {
                        Map<String, Object> callback = new HashMap<>();
                        Map<String, String> data = new HashMap<>();
                        data.put("id", id);
                        data.put("url", url);
                        data.put("coverUrl", coverUrl);
                        callback.put("code", 1);
                        callback.put("msg", "上传成功");
                        callback.put("data", data);
                        result.success(callback);
                    }

                    @Override
                    public void onProgress(long uploadBytes, long totalBytes) {
                        double progress = 1.0 * uploadBytes / totalBytes;
                        mEventSink.success(progress);
                    }

                    @Override
                    public void onFail(int code, String msg) {
                        Map<String, Object> callback = new HashMap<>();
                        callback.put("code", code);
                        callback.put("msg", msg);
                        callback.put("data", null);
                        result.success(callback);
                    }
                });
            }
        } else if (call.method.equals("init")) {
            result.success(true);
        } else {
            result.notImplemented();
        }
    }

    private interface OnLiteUploadListener {
        void onSuc(String id, String url, String coverUrl);

        void onProgress(long uploadBytes, long totalBytes);

        void onFail(int code, String msg);
    }

    private void uploadVideo(Context context, String mCosSignature, String mVideoPath, String mCoverPath, final OnLiteUploadListener onLiteUploadListener) {
        TXUGCPublish mVideoPublish = new TXUGCPublish(context);
        // 文件发布默认是采用断点续传
        TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
        // 需要填写第四步中计算的上传签名
        param.signature = mCosSignature;
        // 录制生成的视频文件路径, ITXVideoRecordListener 的 onRecordComplete 回调中可以获取
        param.videoPath = mVideoPath;
        // 录制生成的视频首帧预览图，ITXVideoRecordListener 的 onRecordComplete 回调中可以获取
        param.coverPath = mCoverPath;
        param.enableHttps = true;
        mVideoPublish.publishVideo(param);
        mVideoPublish.setListener(new TXUGCPublishTypeDef.ITXVideoPublishListener() {
            @Override
            public void onPublishProgress(long uploadBytes, long totalBytes) {
                if (onLiteUploadListener != null) {
                    onLiteUploadListener.onProgress(uploadBytes, totalBytes);
                }
            }

            @Override
            public void onPublishComplete(TXUGCPublishTypeDef.TXPublishResult result) {
                if (onLiteUploadListener != null) {
                    if (result.retCode == 0) {
                        onLiteUploadListener.onSuc(result.videoId, result.videoURL, result.coverURL);
                    } else {
                        onLiteUploadListener.onFail(result.retCode, result.descMsg);
                    }
                }
            }
        });
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        mEventSink.endOfStream();
    }
}
