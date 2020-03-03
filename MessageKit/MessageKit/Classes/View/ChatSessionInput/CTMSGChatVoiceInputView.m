//
//  CTMSGChatVoiceInputView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatVoiceInputView.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"
#import "CTMSGAudioRecordTool.h"
#import "NSTimer+CTMSG_Block.h"
#import "CTMSGVoiceGestureRecognizer.h"
#import <AVFoundation/AVFoundation.h>
//#import "CTMSGVoiceMessageCell.h"

@interface CTMSGChatVoiceInputView () {
    BOOL _shouldResume;
    BOOL _shouldSendWhenFinish;
    BOOL _touching;
}

@property (nonatomic, strong) CAShapeLayer * progressLayer;
@property (nonatomic, strong) CADisplayLink * timer;
@property (nonatomic, assign) float timeSeconds;
@property (nonatomic, assign) float allTime;
@property (nonatomic, assign, readwrite) BOOL recordTooShort;

@end

@implementation CTMSGChatVoiceInputView

- (void)layoutSubviews {
    [super layoutSubviews];
    switch (_viewType) {
        case CTMSGVoiceViewTypeRecord:
            _timeLabel.frame = CGRectMake((self.frame.size.width - 60) / 2, 42, 60, 20);
            break;
        case CTMSGVoiceViewTypePreview:
            _timeLabel.frame = CGRectMake((self.frame.size.width - 60) / 2, 15, 60, 20);
            break;
    }

    CGFloat selfWidth = self.bounds.size.width, selfHeight = self.bounds.size.height;
    CGFloat btnTop = 72, btnWidth = 101;
    _recordImageView.frame = (CGRect){(selfWidth - btnWidth) / 2, btnTop, btnWidth, btnWidth};
    
    CGFloat leading = 15, iconWidth = 60, topToBtn = 30;
    _playIcon.frame = (CGRect){leading, btnTop + (btnWidth - topToBtn) / 2, iconWidth, iconWidth};
    _trashIcon.frame = (CGRect){selfWidth - leading - iconWidth, btnTop + (btnWidth - topToBtn) / 2, iconWidth, iconWidth};
    CGFloat cancelWidth = selfWidth / 2, cancelHeight = 40;
    if (_cancelBtn) {
        _cancelBtn.frame = (CGRect){-1, selfHeight - cancelHeight, cancelWidth + 1, cancelHeight + 1};
    }
    if (_sendBtn) {
        _sendBtn.frame = (CGRect){cancelWidth, selfHeight - cancelHeight, cancelWidth, cancelHeight + 1};
    }
    _playBtn.frame = CGRectMake((selfWidth - btnWidth) / 2, 45, btnWidth, btnWidth);
}

#pragma mark - touch event

- (void)cancelClick:(UIButton *)sender {
    [self cancelRecord];
}

- (void)sendClick:(UIButton *)sender {
    self.viewType = CTMSGVoiceViewTypeRecord;
    [self sendRecord];
}

- (void)cancelRecord {
    _shouldSendWhenFinish = NO;
    _recordImageView.highlighted = NO;
    [self p_playEnd:_playBtn];
    [[CTMSGAudioRecordTool shareRecorder] cancelRecord];
    self.viewType = CTMSGVoiceViewTypeRecord;
    if ([_delegate respondsToSelector:@selector(voiceReocordCancel:)]) {
        [_delegate voiceReocordCancel:self];
    }
    NSLog(@"-------cancel record-----------");
}

- (void)stopRecord:(BOOL)isPreview {
    self.viewType = isPreview ? CTMSGVoiceViewTypePreview : CTMSGVoiceViewTypeRecord;
    if (isPreview) {
        _shouldSendWhenFinish = NO;
    } else {
        _shouldSendWhenFinish = YES;
    }
    float totalTime = [CTMSGAudioRecordTool shareRecorder].currentTime;
    NSLog(@"totalTime : %f befor stop", totalTime);
    if (totalTime < 0.3) {
        _recordTooShort = YES;
    }
    [[CTMSGAudioRecordTool shareRecorder] stopRecord];
    NSLog(@"stopRecord");
}

- (void)sendRecord {
    if (_recordTooShort) {
        if ([_delegate respondsToSelector:@selector(voiceReocordCancel:)]) {
            [_delegate voiceReocordCancel:self];
        }
        self.viewType = CTMSGVoiceViewTypeRecord;
        NSLog(@"recordTooShort");
    } else {
        if ([_delegate respondsToSelector:@selector(voiceReocordEndAndSend:)]) {
            [_delegate voiceReocordEndAndSend:self];
        }
        self.viewType = CTMSGVoiceViewTypeRecord;
        NSLog(@"stop & send");
    }
}

- (void)recordTouched {
    _touching = YES;
    _recordImageView.highlighted = YES;
    _playIcon.hidden = NO;
    _trashIcon.hidden = NO;
    _timeLabel.text = @"松开发送";
    _recordTooShort = NO;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayVoice object:nil];
    BOOL begin = [[CTMSGAudioRecordTool shareRecorder] startRecord];
    if (!begin) {
        self.viewType = CTMSGVoiceViewTypeRecord;
        return;
    }
    [CTMSGAudioRecordTool shareRecorder].recordFinishBlock = ^{
        NSLog(@"------recordFinishBlock--------");
        if (_touching) {
            NSLog(@" max time fired");
            [[_recordImageView gestureRecognizers] enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj reset];
            }];
            self.viewType = CTMSGVoiceViewTypePreview;
        } else {
            if (_shouldSendWhenFinish) {
                [self sendRecord];
            }
        }
        if (_viewType == CTMSGVoiceViewTypePreview) {
            _timeSeconds = [self voiceTime];
            self.timeLabel.text = [NSString stringWithFormat:@"0:%02d", (int)_timeSeconds];
        }
    };
    if ([_delegate respondsToSelector:@selector(voiceReocordStart:)]) {
        [_delegate voiceReocordStart:self];
    }
    NSLog(@"start");
}

- (void)voiceRecordPan:(CTMSGVoiceGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self recordTouched];
            break;
        case UIGestureRecognizerStateChanged:
            if (CGRectContainsPoint(_playIcon.frame, point)) {
                if (!_shouldResume) {
                    _playIcon.highlighted = YES;
                    _recordImageView.highlighted = NO;
                    _timeLabel.text = @"松手试听";
                    [[CTMSGAudioRecordTool shareRecorder] pauseRecord];
                    _shouldResume = YES;
                    NSLog(@"pause");
                }
            } else if (CGRectContainsPoint(_trashIcon.frame, point)) {
                if (!_shouldResume) {
                    _timeLabel.text = @"取消发送";
                    _trashIcon.highlighted = YES;
                    _recordImageView.highlighted = NO;
                    [[CTMSGAudioRecordTool shareRecorder] pauseRecord];
                    _shouldResume = YES;
                    NSLog(@"pause");
                }
            } else {
                if (_shouldResume) {
                    _playIcon.highlighted = NO;
                    _trashIcon.highlighted = NO;
                    _timeLabel.text = @"松开发送";
                    _recordImageView.highlighted = YES;
                    [[CTMSGAudioRecordTool shareRecorder] resumeRecord];
                    _shouldResume = NO;
                    NSLog(@"resume");
                }
            }
            break;
        case UIGestureRecognizerStateEnded: {
            _touching = NO;
            if (_viewType == CTMSGVoiceViewTypePreview) {
                return;
            }
            if (CGRectContainsPoint(_playIcon.frame, point)) {
                [self stopRecord:YES];
            } else if (CGRectContainsPoint(_trashIcon.frame, point)) {
                [self cancelRecord];
            } else {
                [self stopRecord:NO];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            _touching = NO;
            [self stopRecord:NO];
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}

- (void)p_ctmsg_timerupdating {
    _allTime += 0.05;
    [self updateProgress:_allTime / (float)_timeSeconds];
}

- (void)playVoice:(UIButton *)sender {
    if (sender.selected) {
        [self p_playEnd:sender];
        return;
    }
    sender.selected = YES;
    [[CTMSGAudioRecordTool shareRecorder] play];
    _progressLayer.path = nil;
    __weak typeof(self) weakSelf = self;
    _timer = [CADisplayLink displayLinkWithExecuteBlock:^(CADisplayLink *displayLink) {
        [weakSelf p_ctmsg_timerupdating];
    }];
    _timer.frameInterval = 3;
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _allTime = 0;
}

- (void)p_playEnd:(UIButton *)sender {
    sender.selected = NO;
    [[CTMSGAudioRecordTool shareRecorder] stopPlay];
    _progressLayer.path = nil;
    [_timer invalidate];
    _timer = nil;
    _allTime = 0;
}

- (void)setViewType:(CTMSGVoiceViewType)viewType {
    _viewType = viewType;
    _recordTooShort = NO;
    switch (_viewType) {
        case CTMSGVoiceViewTypeRecord:
            self.cancelBtn.hidden = YES;
            self.sendBtn.hidden = YES;
            _playIcon.hidden = YES;
            _trashIcon.hidden = YES;
            _timeLabel.text = @"按住说话";
            _recordImageView.hidden = NO;
            _recordImageView.highlighted = NO;
            _playBtn.hidden = YES;
            break;
        case CTMSGVoiceViewTypePreview:
            self.cancelBtn.hidden = NO;
            self.sendBtn.hidden = NO;
            _playIcon.hidden = YES;
            _trashIcon.hidden = YES;
            _recordImageView.hidden = YES;
            _timeSeconds = [self voiceTime];
            self.timeLabel.text = [NSString stringWithFormat:@"0:%02d", (int)_timeSeconds];
            self.playBtn.hidden = NO;
            break;
    }
    [self setNeedsLayout];
}

- (void)updateProgress:(CGFloat)value {
    NSLog(@"%f", value);
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:_playBtn.center radius:(100 - 10) / 2 + 5 startAngle:- M_PI_2 endAngle:2 * M_PI * (value) - M_PI_2 clockwise:YES];
    self.progressLayer.path = path.CGPath;
}
 
- (float)voiceTime {
    NSString *wavPath = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:wavPath] options:opts]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = (NSUInteger)(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒
    second = MAX(1.0, second);
    return second;
}

#pragma mark - lazy

//- (UIImageView *)animatedImage {
//    if (!_animatedImage) {
//        _animatedImage = ({
//            UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@""]];
//            imageView;
//        });
//    }
//    return _animatedImage;
//}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor ctmsg_colorWithRGB:0x31a3ff] forState:UIControlStateNormal];
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor ctmsg_colorD9D9D9].CGColor;
            [self addSubview:button];
            button;
        });
    }
    return _cancelBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(sendRecord) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"发送" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor ctmsg_colorWithRGB:0x31a3ff] forState:UIControlStateNormal];
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor ctmsg_colorD9D9D9].CGColor;
            [self addSubview:button];
            button;
        });
    }
    return _sendBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_record_play"] forState:UIControlStateNormal];
            [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_record_playstop"] forState:UIControlStateSelected];
            button.backgroundColor = [UIColor ctmsg_colorD9D9D9];
            button.layer.cornerRadius = 50.5;
            [self addSubview:button];
            [self.layer insertSublayer:_progressLayer above:button.layer];
            button;
        });
    }
    return _playBtn;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    self.clipsToBounds = YES;
    _timeLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"按住说话";
        label.textColor = [UIColor ctmsg_color7F7F7F];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label;
    });
    
    _recordImageView = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_n"]];
        imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_s"];
        imageView.userInteractionEnabled = YES;
        CTMSGVoiceGestureRecognizer * ges = [[CTMSGVoiceGestureRecognizer alloc] initWithTarget:self action:@selector(voiceRecordPan:)];
        [imageView addGestureRecognizer:ges];
        [self addSubview:imageView];
        imageView;
    });
    
    _playIcon = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_n"]];
        imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_h"];
        imageView.hidden = YES;
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        imageView;
    });
    
    _trashIcon = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_n"]];
        imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_h"];
        imageView.hidden = YES;
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        imageView;
    });
    
    __weak typeof(self) weakSelf = self;
    [CTMSGAudioRecordTool shareRecorder].playFinishBlock = ^{
        [weakSelf p_playEnd:weakSelf.playBtn];
    };
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = [UIColor ctmsg_color8358D0].CGColor;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineWidth = 2;
    _progressLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_progressLayer];
    self.viewType = CTMSGVoiceViewTypeRecord;
    
    _shouldResume = NO;
    _shouldSendWhenFinish = YES;
    _touching = NO;
    _recordTooShort = NO;
}

@end
