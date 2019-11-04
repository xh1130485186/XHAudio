//
//  XHAudioControl.h
//  XHKitDemo
//
//  Created by 向洪 on 2019/11/4.
//  Copyright © 2019 向洪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 是否隐藏遮罩， 默认为no
@interface XHAudioControl : UIView

/// 初始化 (高度设置最好大于300.0)
/// @param size 显示视图带大小
- (instancetype)initWithSize:(CGSize)size;

// 显示，隐藏
- (void)show;
- (void)show:(nullable UIView *)displayView;
- (void)hide;

/// 是否隐藏遮罩， 默认为no
@property (nonatomic, assign) BOOL isHideMask;

/// 高斯模糊
@property (nonatomic, strong, readonly) UIVisualEffectView *effectView;

@end

NS_ASSUME_NONNULL_END
