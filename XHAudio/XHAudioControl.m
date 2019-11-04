//
//  XHAudioControl.m
//  XHKitDemo
//
//  Created by 向洪 on 2019/11/4.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "XHAudioControl.h"

#define UIScreen_Frame _displayView.frame
#define KEYWINDOW [[[UIApplication sharedApplication] delegate] window]

@interface XHAudioControl ()

@property (nonatomic, weak) UIView *displayView;
@property (nonatomic, strong) UIVisualEffectView *effectView; // 高斯模糊
@property (nonatomic, strong) UIButton *mask; // 遮罩
@property (nonatomic) CGSize size;

@property (nonatomic, strong) NSMutableArray *constraintsCache;

@end

@implementation XHAudioControl

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        [self initialize_container];
    }
    return self;
}

- (void)initialize_container {
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:243/255.f alpha:0.8];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 模糊效果
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self insertSubview:self.effectView atIndex:0];
    self.effectView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_effectView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_effectView)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_effectView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_effectView)]];
    [self addConstraints:constraints];
}

#pragma mark - 显示和隐藏

- (void)show {
    [self show:nil];
}

- (void)show:(nullable UIView *)displayView {
    
    if (!displayView) {
        displayView = KEYWINDOW;
    }
    self.displayView = displayView;
    [displayView endEditing:YES];
    [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
        
        self.mask.alpha = 0.3;
        NSLayoutConstraint *contstraint = self.constraintsCache[3];
        contstraint.constant = 0;
        [self.displayView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
}

- (void)hide {
    [self endEditing:YES];
    [self.displayView layoutIfNeeded];
    [UIView animateWithDuration:0.25 delay:0 options:8<<16 animations:^{
        
        self.mask.alpha = 0;
    
        NSLayoutConstraint *contstraint = self.constraintsCache[3];
        contstraint.constant = -self.size.height;
        [self.displayView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.displayView = nil;
    }];
}

- (void)setDisplayView:(UIView *)displayView {
    
    if (displayView) {
        
        if ([displayView isEqual:_displayView]) {
            return;
        }
        
        if (self.superview) {
            [self removeFromSuperview];
        }
        if (_mask.superview) {
            [_mask removeFromSuperview];
        }
        
        [displayView addSubview:self.mask];
        self.mask.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *maskConstraints = [NSMutableArray array];
        [maskConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_mask]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mask)]];
        [maskConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_mask]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mask)]];
        [displayView addConstraints:maskConstraints];
        
        [displayView addSubview:self];
        
        [self.displayView removeConstraints:self.constraintsCache];
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[self]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[self(%lf)]-(%lf)-|", self.size.height, -self.size.height] options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
        self.constraintsCache = constraints;
        [displayView addConstraints:constraints];
        [displayView layoutIfNeeded];
        
        _displayView = displayView;
    } else {
        [self removeFromSuperview];
        [_mask removeFromSuperview];
        _displayView = nil;
    }
}


- (void)setIsHideMask:(BOOL)isHideMask {
    
    _isHideMask = isHideMask;
    _mask.hidden = isHideMask;
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    _size = frame.size;
}

#pragma mark - 遮罩

- (UIButton *)mask {
    
    if (!_mask) {
        _mask = [UIButton buttonWithType:UIButtonTypeCustom];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0;
        [_mask addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mask;
}


@end
