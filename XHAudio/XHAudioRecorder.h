//
//  XHAudioRecorder.h
//  XHKitDemo
//
//  Created by 向洪 on 2017/6/26.
//  Copyright © 2017年 向洪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XHAudioRecorderDelegate;

/// 对语音AVAudioRecorder录制的一个封装。不需要很多配置，调用更加简单
@interface XHAudioRecorder : NSObject

@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;
@property (nonatomic, weak) id<XHAudioRecorderDelegate> delegate;

/// 开始录制
- (BOOL)record;

/// 指定在某个时间开始录制，基于设备当前时间
- (BOOL)recordAtTime:(NSTimeInterval)time;

/// 指定持续时间的录制。时间结束后就会停止
- (BOOL)recordForDuration:(NSTimeInterval)duration;
 
///  指定在某个时间开始，最大持续时间的录制
- (BOOL)recordAtTime:(NSTimeInterval)time forDuration:(NSTimeInterval) duration;

/// 结束录制的时候调用，如果url为nil 那么录制失败
@property (nonatomic, copy) void(^recorderDidFinishRecordingHandler) (NSURL *outputUrl, NSTimeInterval duration);

/// 录制进度，这个方法1s会调用一次，使用NSTimer，所有返回的时间并不完成和录音时间相同
@property (nonatomic, copy) void(^recorderProgressHandler) (NSTimeInterval recordTime);

/// 暂停
- (void)pause;
/// 停止
- (void)stop;
/// 删除这次录制文件，这个操作会停止这次录制。
- (void)deleteRecording;

@end

@protocol XHAudioRecorderDelegate <NSObject>

@optional
/// 录音中断
/// @param recorder 录音类
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder;

/// 录音中断结束，可以恢复录音，
/// @param recorder 中断的进行中的录音
/// @param flags 为1表示可以恢复录音
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags;

/// 录音权限获取
/// @param canRecord 是否有权限录音
- (void)audioRecorderPermission:(BOOL)canRecord;

/// 准备录音
/// @param prepare 是否准备成功
- (void)audioRecordertoPrepareToRecord:(BOOL)prepare;

@end;
