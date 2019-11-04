//
//  XHAudioRecordView.m
//  GrowthCompassT3
//
//  Created by 向洪 on 2019/10/12.
//  Copyright © 2019 向洪. All rights reserved.
//

#import "XHAudioRecordView.h"
#import "XHAudioRecorder.h"
#import "XHAudioPlayerDefines.h"

@interface XHAudioRecordView () <XHAudioRecorderDelegate>

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) XHAudioRecorder *audioReorder;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isCanceling;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation XHAudioRecordView

+ (instancetype)recordWithDuration:(NSTimeInterval)duration {
    XHAudioRecordView *recordView = [[XHAudioRecordView alloc] initWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 245)];
    recordView.duration = duration;
    [recordView setupUI];
    return recordView;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 0;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:15];
    _timeLabel.textColor = [UIColor colorWithWhite:102/255.f alpha:1];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"长按开始录音";
    [self addSubview:_timeLabel];
    
    _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton.userInteractionEnabled = NO;
    [_recordButton setImage:XHAudioImage(@"btn_soundrecording") forState:UIControlStateNormal];
    //    [_recordButton addTarget:self action:@selector(endAction) forControlEvents:UIControlEventTouchCancel];
    [self addSubview:_recordButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.userInteractionEnabled = NO;
    _cancelButton.hidden = YES;
    [_cancelButton setImage:XHAudioImage(@"btn_soundrecording_del") forState:UIControlStateNormal];
    //    [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:_cancelButton];
    
    NSMutableArray *constraints = [NSMutableArray array];
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:48]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-90-[_recordButton(108)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_recordButton)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_recordButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_recordButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_recordButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cancelButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_recordButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cancelButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_recordButton attribute:NSLayoutAttributeLeft multiplier:1 constant:-40]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:45]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_cancelButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self addConstraints:constraints];

}

- (XHAudioRecorder *)audioReorder {
    
    if (!_audioReorder) {
        
        _audioReorder = [[XHAudioRecorder alloc] init];
        _audioReorder.delegate = self;

        __weak __typeof(self)weakSelf = self;
        
        _audioReorder.recorderDidFinishRecordingHandler = ^(NSURL *outputUrl, NSTimeInterval duration) {
            if (!weakSelf.isCanceling && outputUrl) {
                if (weakSelf.recordDidFinishRecordingHandler) {
                    weakSelf.recordDidFinishRecordingHandler(outputUrl, duration);
                }
            } else {
                if (weakSelf.recordDidFinishRecordingHandler) {
                    weakSelf.recordDidFinishRecordingHandler(nil, 0);
                }
            }
            [weakSelf stopRecord];
        };
        
        _audioReorder.recorderProgressHandler = ^(NSTimeInterval recordTime) {
            NSString *time = [NSString stringWithFormat:@"%02li:%02li",lround(floor(recordTime/60.f)), lround(floor(recordTime/1.f))%60];
            weakSelf.timeLabel.text = time;
            weakSelf.shapeLayer.strokeEnd = recordTime/weakSelf.duration;
        };
        
    }
    return _audioReorder;
}

/// 开始录制
- (void)startRecord {
    if (!_isRecording) {
        _recordButton.highlighted = YES;
        _cancelButton.hidden = NO;
        _isRecording = YES;
        [_audioReorder deleteRecording];
        
        if (![self.audioReorder recordForDuration:_duration]) {
            _timeLabel.text = @"启动录音失败";
        } else {
            _timeLabel.text = @"初始化中";
        }
    
        _shapeLayer.hidden = NO;
    }
}

/// 结束录制
- (void)stopRecord {
    if (_isRecording) {

        _isRecording = NO;
        
        [_audioReorder stop];
        
        _recordButton.highlighted = NO;
        _cancelButton.highlighted = NO;
        _timeLabel.text = @"长按开始录音";
        _cancelButton.hidden = YES;
        
        _shapeLayer.hidden = YES;
        _shapeLayer.strokeEnd = 0;
        
    }
}

// 触摸开始，判断开始录制
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    __block CGPoint point = CGPointZero;
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        point = [obj locationInView:self];
    }];

    if (CGRectContainsPoint(_recordButton.frame, point)) {
        // 开始录制
        [self startRecord];
    }

}

// 触摸滑动，滑动的时候改变视图显示状态，进行不同的操作
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_isRecording) {
        
        __block CGPoint point = CGPointZero;
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
            point = [obj locationInView:self];
        }];
        
        BOOL contains = CGRectContainsPoint(_cancelButton.frame, point);
        if (contains && _recordButton.highlighted) {
            _recordButton.highlighted = NO;
            _cancelButton.highlighted = YES;
            
        } else if (!contains && !_recordButton.highlighted) {
            _recordButton.highlighted = YES;
            _cancelButton.highlighted = NO;
        }
        
    }
    
}

// 触摸结束，判断结束录音，以及结束录音的状态
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    // 结束录音
    __block CGPoint point = CGPointZero;
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        point = [obj locationInView:self];
    }];
    BOOL contains = CGRectContainsPoint(_cancelButton.frame, point);
    
    if (contains) {
        // 放弃
        _isCanceling = YES;
    } else {
    }

    [self stopRecord];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isCanceling = YES;
    [self stopRecord];
}

#pragma mark - delegate <XHAudioRecorderDelegate>

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    [self stopRecord];
}

- (void)audioRecorderPermission:(BOOL)canRecord {
    
    if (!canRecord) {
//        [XHAlertController alertWithMessage:@"没有获取到权限" sure:^{
//            [self show];
//        }];
//        [self hide];
    }
}

- (void)audioRecordertoPrepareToRecord:(BOOL)prepare {
    if (!prepare) {
//        [XHAlertController alertWithMessage:@"录音初始化失败" sure:^{
//            [self show];
//        }];
//        [self hide];
    }
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        
        CGFloat width = self.recordButton.frame.size.width;
        CGFloat positionX = width/2;
        CGFloat positionY = positionX;
        
        CGFloat radius = MIN(positionX, positionY)-6*0.5;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(positionX, positionY) radius:radius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = CGRectMake(0, 0, width, width);
        shapeLayer.position = self.recordButton.center;
        shapeLayer.path = path.CGPath;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineWidth = 6;
        shapeLayer.strokeEnd = 0;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor colorWithRed:38/255.f green:176/255.f blue:62/255.f alpha:1].CGColor;
        
        _shapeLayer = shapeLayer;
        
        [self.layer addSublayer:shapeLayer];
    }
    return _shapeLayer;
}

@end
