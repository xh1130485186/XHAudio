//
//  XHAudioPlayer.h
//  GrowthCompassT3
//
//  Created by 向洪 on 2019/10/9.
//  Copyright © 2019 向洪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XHAudioPlayerDelegate;

NS_ASSUME_NONNULL_BEGIN

/// 音频播放
/// 暂不支持后台播放
@interface XHAudioPlayer : NSObject

@property (nullable, nonatomic, strong) NSURL *url; ///< 地址，支持网络路径
@property (nullable, nonatomic, strong) AVPlayerItem *currentItem; ///< 当前播放对象
@property (nullable, nonatomic, strong, readonly) AVPlayer *player; ///< 播放器
@property (nullable, nonatomic, weak) id<XHAudioPlayerDelegate> delegate; ///< 代理
@property (readonly, getter=isPlaying) BOOL playing; ///< 是否正在播放
@property (readonly, getter=isFailed) BOOL failed; ///< 失败

/// 播放
- (void)play;
/// 暂停
- (void)pause;

///// 单列创建
//+ (XHAudioPlayer *)sharedInstance;

@end

@protocol XHAudioPlayerDelegate <NSObject>

@optional

/// 将要加载资源的时候调用
- (void)audioPlayerWillLoading:(XHAudioPlayer *)audioPlayer;

/// 播放器准备好播放的时候调用
- (void)audioPlayerDidReadyToPlay:(XHAudioPlayer *)audioPlayer currentItem:(AVPlayerItem *)item;

/// 播放器加载资源失败的时候调用
- (void)audioPlayerDidLoadingFailed:(XHAudioPlayer *)audioPlayer;

/// 暂停的时候调用
- (void)audioPlayerPausePlaying:(XHAudioPlayer *)audioPlayer;

/// 结束播放的时候调用，isToEndTime是否当结束结束而结束播放
- (void)audioPlayerDidFinishPlaying:(XHAudioPlayer *)audioPlayer toEndTime:(BOOL)isToEndTime;

@end

///// 将要加载资源的时候调用
//extern NSString * const XHAudioPlayerWillLoadingNotification;
///// 播放器准备好播放的时候调用
//extern NSString * const XHAudioPlayerDidReadyToPlayNotification;
///// 播放器加载资源失败的时候调用
//extern NSString * const XHAudioPlayerDidLoadingFailedNotification;

extern NSString * const XHAudioPlayerStartPlayingNotification; ///< 播放的时候调用
///// 暂停播放调用
//extern NSString * const XHAudioPlayerPausePlayingNotification;
///// 停止播放调用
//extern NSString * const XHAudioPlayerDidFinishPlayingNotification;

///// 通知返回值，AVPlayerItem
//extern NSString * const kNotificationUerInfoPlayerItem;

NS_ASSUME_NONNULL_END
