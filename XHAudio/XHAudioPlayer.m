//
//  XHAudioPlayer.m
//  GrowthCompassT3
//
//  Created by 向洪 on 2019/10/9.
//  Copyright © 2019 向洪. All rights reserved.
//

//NSString * const XHAudioPlayerWillLoadingNotification = @"xh.audioPlayer.willLoading";
//NSString * const XHAudioPlayerDidReadyToPlayNotification = @"xh.audioPlayer.didReadyToPlay";
//NSString * const XHAudioPlayerDidLoadingFailedNotification = @"xh.audioPlayer.didLoadingFailed";

//NSString * const XHAudioPlayerDidFinishPlayingNotification = @"xh.audioPlayer.didFinishPlaying";
//NSString * const XHAudioPlayerPausePlayingNotification = @"xh.audioPlayer.pausePlaying";

//NSString * const kNotificationUerInfoPlayerItem = @"xh.audioPlayer.notificationUerInfo.playerItem";

#import "XHAudioPlayer.h"

NSString * const XHAudioPlayerStartPlayingNotification = @"xh.audioPlayer.startPlaying";

@interface XHAudioPlayer () {
    AVPlayer *_player;
    BOOL _failed;
    AVAudioSessionCategory _category;
}

@end

@implementation XHAudioPlayer

///// 单列创建
//+ (XHAudioPlayer *)sharedInstance {
//    static XHAudioPlayer *player;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        player = [[XHAudioPlayer alloc] init];
//    });
//    return player;
//}

- (void)play {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    _category = session.category;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    
    _playing = YES;
    [_player play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerStartPlayingNotification object:self userInfo:nil];
}

- (void)pause {
    
    _playing = NO;
    
    [_player pause];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerPausePlayingNotification object:self userInfo:nil];
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerPausePlaying:)]) {
        [self.delegate audioPlayerPausePlaying:self];
    }
    
    [[AVAudioSession sharedInstance] setCategory:_category error:nil];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 状态更改
    if ([keyPath isEqualToString:@"player.currentItem.status"]) {
    
        
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            // 播放器准备好播放
            _failed = NO;
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerDidReadyToPlay:currentItem:)]) {
                [self.delegate audioPlayerDidReadyToPlay:self currentItem:self.player.currentItem];
            }
        } else if (status == AVPlayerItemStatusFailed) {
            // 播放器加载资源失败
            _failed = YES;
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerDidLoadingFailed:)]) {
                [self.delegate audioPlayerDidLoadingFailed:self];
            }
        } else if (status == AVPlayerItemStatusUnknown) {
            // 将要加载资源
            _failed = NO;
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerWillLoading:)]) {
                [self.delegate audioPlayerWillLoading:self];
            }
        }
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
    
//        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
//        NSLog(@"%ld", status);
//        NSDictionary *dic = @{kNotificationUerInfoPlayerItem:self.currentItem};
//        if (status == AVPlayerItemStatusReadyToPlay) {
//            // 播放器准备好播放
//            [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerDidReadyToPlayNotification object:nil userInfo:dic];
//        } else if (status == AVPlayerItemStatusFailed) {
//            // 播放器加载资源失败
//            [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerDidLoadingFailedNotification object:nil userInfo:dic];
//        } else if (status == AVPlayerItemStatusUnknown) {
//            // 将要加载资源
//            [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerWillLoadingNotification object:nil userInfo:dic];
//        }
    }
}

#pragma mark - Notification

- (void)didPlayToEndTimeNotification:(NSNotification *)noti {
//    [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerDidFinishPlayingNotification object:self userInfo:nil];
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:toEndTime:)]) {
        [self.delegate audioPlayerDidFinishPlaying:self toEndTime:YES];
    }
    
    [[AVAudioSession sharedInstance] setCategory:_category error:nil];
}

- (void)failedToPlayToEndTimeNotification:(NSNotification *)noti {
//    [[NSNotificationCenter defaultCenter] postNotificationName:XHAudioPlayerDidFinishPlayingNotification object:self userInfo:nil];
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(XHAudioPlayerDelegate)] && [self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:toEndTime:)]) {
        [self.delegate audioPlayerDidFinishPlaying:self toEndTime:NO];
    }
    
    [[AVAudioSession sharedInstance] setCategory:_category error:nil];
}

#pragma mark - Setter Methods

- (void)setUrl:(NSURL *)url {
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.currentItem = playerItem;
}

- (void)setCurrentItem:(AVPlayerItem *)currentItem {
    
    _currentItem = currentItem;
    if ([currentItem.asset isKindOfClass:[AVURLAsset class]]) {
        AVURLAsset *asset = (AVURLAsset *)currentItem.asset;
        _url = asset.URL;
    }
    
    if (_player) {
        //        [self pause];
        [_player replaceCurrentItemWithPlayerItem:currentItem];
        
    } else {
        _player = [[AVPlayer alloc] initWithPlayerItem:currentItem];
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToPlayToEndTimeNotification:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    }
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
}

@end

