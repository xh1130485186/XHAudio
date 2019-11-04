//
//  XHAudioRecordView.h
//  GrowthCompassT3
//
//  Created by 向洪 on 2019/10/12.
//  Copyright © 2019 向洪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHAudioControl.h"

NS_ASSUME_NONNULL_BEGIN

/// 录音，点击开始录音的时候，如果这个实列进行过录音，会清除之前的录音文件。
@interface XHAudioRecordView : XHAudioControl

/// 初始化
/// @param duration 录制的最大时间，到时间后自动结束
+ (instancetype)recordWithDuration:(NSTimeInterval)duration;

/// 录音结束调用
@property (nonatomic, copy) void(^recordDidFinishRecordingHandler) (NSURL *__nullable outputUrl, NSTimeInterval duration);

@end

NS_ASSUME_NONNULL_END
