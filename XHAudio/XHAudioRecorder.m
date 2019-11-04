//
//  XHAudioRecorder.m
//  XHKitDemo
//
//  Created by 向洪 on 2017/6/26.
//  Copyright © 2017年 向洪. All rights reserved.
//

#import "XHAudioRecorder.h"

@interface XHAudioRecorder () <AVAudioRecorderDelegate> {
    AVAudioRecorder *_audioRecorder;
    NSString *_sessionCategory;
    CADisplayLink *_displayLink;
    NSTimeInterval _duration;
}

@end

@implementation XHAudioRecorder

#pragma mark - init

- (instancetype)init {

    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    /*
     
     音频基础
     
     声波是一种机械波，是一种模拟信号。
     PCM，全称脉冲编码调制，是一种模拟信号的数字化的方法。
     采样精度（bit pre sample)，每个声音样本的采样位数。
     采样频率（sample rate）每秒钟采集多少个声音样本。
     声道（channel）：相互独立的音频信号数，单声道（mono）立体声（Stereo）
     语音帧（frame），In audio data a frame is one sample across all channels.
     
     */
    
    // 权限判断
    
    BOOL canRecord = [self canRecord];
    if (_delegate && [_delegate conformsToProtocol:@protocol(XHAudioRecorderDelegate)] && [_delegate respondsToSelector:@selector(audioRecorderPermission:)]) {
        [_delegate audioRecorderPermission:canRecord];
    }
    if (!canRecord) {
        return;
    }
    
    // 语音录制
    
    // 格式（真机）
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSString *outputPath = nil;
    // 输出地址
#if TARGET_IPHONE_SIMULATOR//模拟器
    outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", [[NSUUID UUID] UUIDString]]];
    // 设置录音格式
    [recordSetting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    
#elif TARGET_OS_IPHONE//真机
    
    outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", [[NSUUID UUID] UUIDString]]];
    [recordSetting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    
#endif
    
    // 设置录音采样率
    [recordSetting setObject:@(8000) forKey:AVSampleRateKey];
    // 设置通道,这里采用单声道 1:单声道；2:立体声
    [recordSetting setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分为8、16、24、32
    [recordSetting setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    
    // 大端还是小端,是内存的组织方式
//    [recordSetting setObject:@(NO) forKey:AVLinearPCMIsBigEndianKey];
    // 是否使用浮点数采样
    [recordSetting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // 是否交叉
//    [recordSetting setObject:@(NO) forKey:AVLinearPCMIsNonInterleaved];
    
    // 设置录音质量
    [recordSetting setObject:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    
//    // 比特率
//    [recordSetting setObject:@(128000) forKey:AVEncoderBitRateKey];
//    // 每个声道音频比特率
//    [recordSetting setObject:@(128000) forKey:AVEncoderBitRatePerChannelKey];
//    
//    // 深度
//    [recordSetting setObject:@(8) forKey:AVEncoderBitDepthHintKey];
    
    // 设置录音采样质量
    [recordSetting setObject:@(AVAudioQualityMin) forKey:AVSampleRateConverterAudioQualityKey];
    
    // 初始化
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:outputPath] settings:recordSetting error:&error];
    // 设置协议
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;
    
    
    // 准备录制
    BOOL prepare = [_audioRecorder prepareToRecord];
    if (_delegate && [_delegate conformsToProtocol:@protocol(XHAudioRecorderDelegate)] && [_delegate respondsToSelector:@selector(audioRecordertoPrepareToRecord:)]) {
        [_delegate audioRecordertoPrepareToRecord:prepare];
    }
    if (!prepare) {
        NSLog(@"准备失败");
        return;
    }
    if (error) {
        NSLog(@"%@", error);
    }
    
}

- (void)recordInit {
    
    [self.displayLink setPaused:NO];
    /** 注册音频录制中断通知 */
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(sessionInterruptionNotificationWithNotification:) name:AVAudioSessionInterruptionNotification object:nil];
}


#pragma mark - public Methods

- (BOOL)record {
    
    [self sessionSetPlayAndRecordCategory];
    BOOL record = [_audioRecorder record];
    if (record) {
        [self recordInit];
    }
    return record;
}

- (BOOL)recordAtTime:(NSTimeInterval)time {
    
    [self sessionSetPlayAndRecordCategory];
    BOOL record = [_audioRecorder recordAtTime:time];
    if (record) {
        [self recordInit];
    }
    return record;
}

- (BOOL)recordForDuration:(NSTimeInterval)duration {

    _duration = duration;
    
    [self sessionSetPlayAndRecordCategory];
    BOOL record = [_audioRecorder recordForDuration:duration];
    if (record) {
        [self recordInit];
    }
    return record;
}

- (BOOL)recordAtTime:(NSTimeInterval)time forDuration:(NSTimeInterval) duration {

    [self sessionSetPlayAndRecordCategory];
    BOOL record = [_audioRecorder recordAtTime:time forDuration:duration];
    if (record) {
        [self recordInit];
    }
    return record;
}

- (void)pause {
    
    [_audioRecorder pause];
    [_displayLink setPaused:YES];
}

- (void)stop {
    
    [_audioRecorder stop];
    [self sessionRestoreCategory];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)deleteRecording {
    if (_audioRecorder.isRecording) {
        [self stop];
    }
    [_audioRecorder deleteRecording];
    [_displayLink setPaused:YES];
}

#pragma mark - AVAudioRecorderDelegate

// 录音结束
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    NSLog(@"录音结束");
    if (self.recorderDidFinishRecordingHandler) {
        if (flag) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:recorder.url options:nil];
            NSTimeInterval seconds = CMTimeGetSeconds(asset.duration);
            self.recorderDidFinishRecordingHandler(recorder.url, seconds);
        } else {
            self.recorderDidFinishRecordingHandler(nil, 0);
        }
    }
    self.displayLink.paused = YES;
}

// 发生错误调用
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
    NSLog(@"录音发送错误");
    if (self.recorderDidFinishRecordingHandler) {
        self.recorderDidFinishRecordingHandler(nil, 0);
    }
    self.displayLink.paused = YES;;
}


#pragma mark - AVAudioSession

- (BOOL)canRecord{
    
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    return bCanRecord;
}

- (void)sessionSetPlayAndRecordCategory {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    _sessionCategory = session.category;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

- (void)sessionRestoreCategory {
    
    // 此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:_sessionCategory error:nil];
    [session setActive:YES error:nil];
}

// 接收录制中断事件通知，并处理相关事件
- (void)sessionInterruptionNotificationWithNotification:(NSNotification *)notification {
    
    NSArray *allKeys = notification.userInfo.allKeys;
    // 判断事件类型
    if([allKeys containsObject:AVAudioSessionInterruptionTypeKey]){
        AVAudioSessionInterruptionType audioInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
        switch (audioInterruptionType) {
            case AVAudioSessionInterruptionTypeBegan:
                _displayLink.paused = YES;
                if (_delegate && [_delegate conformsToProtocol:@protocol(XHAudioRecorderDelegate)] && [_delegate respondsToSelector:@selector(audioRecorderBeginInterruption:)]) {
                    [_delegate audioRecorderBeginInterruption:self.audioRecorder];
                }
                if (self) {
                    if (self.recorderDidFinishRecordingHandler) {
                        self.recorderDidFinishRecordingHandler(nil, 0);
                    }
                }
//                NSLog(@"%@ %lf", @"录音被打断…… 开始", self.audioRecorder.currentTime);
                break;
            case AVAudioSessionInterruptionTypeEnded:
                break;
        }
    }
    // 判断中断的音频录制是否可恢复录制
    if([allKeys containsObject:AVAudioSessionInterruptionOptionKey]){
        AVAudioSessionInterruptionOptions shouldResume = [[notification.userInfo valueForKey:AVAudioSessionInterruptionOptionKey] integerValue];
        if(shouldResume){
            
            self.displayLink.paused = NO;
            if (_delegate && [_delegate conformsToProtocol:@protocol(XHAudioRecorderDelegate)] && [_delegate respondsToSelector:@selector(audioRecorderEndInterruption:withOptions:)]) {
                [_delegate audioRecorderBeginInterruption:self.audioRecorder];
            }
//            NSLog(@"录音被打断…… 结束 可以恢复录音了 %lf", self.audioRecorder.currentTime);
        }
    }
    
}

#pragma mark - displayLink

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)displayLinkAction {
    
    if (self.recorderProgressHandler) {
        self.recorderProgressHandler(_audioRecorder.currentTime);
    }
    if (_audioRecorder.currentTime >= _duration) {
        // 超时
        [self stop];
    }
}

- (void)dealloc {
    _displayLink.paused = YES;
    [_displayLink invalidate];
    _displayLink = nil;
}

@end
