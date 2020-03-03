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

@implementation CTMSGChatVoiceInputView

- (void)layoutSubviews {
    CGFloat selfWidth = self.bounds.size.width, selfHeight = self.bounds.size.height;
    CGFloat btnTop = 42, btnWidth = 101, btnHeight = 130;
    _recordBtn.frame = (CGRect){(selfWidth - btnWidth) / 2, btnTop, btnWidth, btnHeight};
    
    CGFloat leading = 15, iconWidth = 36, topToBtn = 30;
//    if (_playIcon) {
        _playIcon.frame = (CGRect){leading, btnTop + (btnHeight - topToBtn) / 2, iconWidth, iconWidth};
//    }
//    if (_trashIcon) {
        _trashIcon.frame = (CGRect){selfWidth - leading - iconWidth, btnTop + (btnHeight - topToBtn) / 2, iconWidth, iconWidth};
//    }
    CGFloat cancelWidth = selfWidth / 2, cancelHeight = 40;
    if (_cancelBtn) {
        _cancelBtn.frame = (CGRect){0, selfHeight - cancelHeight, cancelWidth, cancelHeight};
    }
    if (_sendBtn) {
        _sendBtn.frame = (CGRect){cancelWidth, selfHeight - cancelHeight, cancelWidth, cancelHeight};
    }
}

#pragma mark - touch event

- (void)cancelClick:(UIButton *)sender {
    [self cancelRecord:_recordBtn];
}

- (void)sendClick:(UIButton *)sender {
    [self sendRecord:_recordBtn];
}

- (void)cancelRecord:(UIButton *)sender {
    sender.highlighted = NO;
    _playIcon.hidden = YES;
    _trashIcon.hidden = YES;
    _playIcon.highlighted = NO;
    _trashIcon.highlighted = NO;
    [_recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [[CTMSGAudioRecordTool shareRecorder] cancelRecord];
    if ([_delegate respondsToSelector:@selector(voiceReocordCancel:)]) {
        [_delegate voiceReocordCancel:self];
    }
    NSLog(@"cancel");
}

- (void)sendRecord:(UIButton *)sender {
    sender.highlighted = NO;
    _playIcon.hidden = YES;
    _trashIcon.hidden = YES;
    _playIcon.highlighted = NO;
    _trashIcon.highlighted = NO;
    _cancelBtn.hidden = YES;
    _sendBtn.hidden = YES;
    [_recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [[CTMSGAudioRecordTool shareRecorder] stopRecord];
    if ([_delegate respondsToSelector:@selector(voiceReocordEndAndSend:)]) {
        [_delegate voiceReocordEndAndSend:self];
    }
    NSLog(@"stop & send");
}

- (void)playVoice {
    _playIcon.hidden = YES;
    _trashIcon.hidden = YES;
    self.cancelBtn.hidden = NO;
    self.sendBtn.hidden = NO;
    [self setNeedsLayout];
    [[CTMSGAudioRecordTool shareRecorder] stopRecord];
    [[CTMSGAudioRecordTool shareRecorder] play];
    NSLog(@"play");
}

- (void)recordTouched:(UIButton *)sender {
    sender.highlighted = YES;
    _playIcon.hidden = NO;
    _trashIcon.hidden = NO;
    [sender setTitle:@"松开发送" forState:UIControlStateNormal];
    [[CTMSGAudioRecordTool shareRecorder] startRecord];
    if ([_delegate respondsToSelector:@selector(voiceReocordStart:)]) {
        [_delegate voiceReocordStart:self];
    }
    NSLog(@"start");
}

//- (void)recordEnded:(UIButton *)sender {
//    sender.highlighted = NO;
//}

- (void)voiceBtnPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
//    NSLog(@"%@", NSStringFromCGPoint(point));
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
//            [self recordTouched:_recordBtn];
            break;
        case UIGestureRecognizerStateChanged:
            _playIcon.highlighted = NO;
            _trashIcon.highlighted = NO;
            if (CGRectContainsPoint(_playIcon.frame, point)) {
                _playIcon.highlighted = YES;
                _recordBtn.highlighted = NO;
                [_recordBtn setTitle:@"松手试听" forState:UIControlStateNormal];
                [[CTMSGAudioRecordTool shareRecorder] pauseRecord];
                NSLog(@"pause");
            } else if (CGRectContainsPoint(_trashIcon.frame, point)) {
                _trashIcon.highlighted = YES;
                _recordBtn.highlighted = NO;
                [[CTMSGAudioRecordTool shareRecorder] pauseRecord];
                NSLog(@"pause");
                [_recordBtn setTitle:@"取消发送" forState:UIControlStateNormal];
            } else {
                _recordBtn.highlighted = YES;
                [[CTMSGAudioRecordTool shareRecorder] resumeRecord];
                NSLog(@"resume");
                [_recordBtn setTitle:@"松开发送" forState:UIControlStateNormal];
            }
            break;
        case UIGestureRecognizerStateEnded: {
//            if (CGRectContainsPoint(_recordBtn.frame, point)) {
//                [self recordTouched:_recordBtn];
//            } else {
            if (CGRectContainsPoint(_playIcon.frame, point)) {
                [self playVoice];
            } else if (CGRectContainsPoint(_trashIcon.frame, point)) {
                [self cancelRecord:_recordBtn];
            } else {
                [self sendRecord:_recordBtn];
            }
//            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            [self sendRecord:_recordBtn];
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
}

#pragma mark - lazy
//- (UIImageView *)playIcon {
//    if (!_playIcon) {
//        _playIcon = ({
//            UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_n"]];
//            imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_h"];
//            imageView;
//        });
//    }
//    return _playIcon;
//}
//
//- (UIImageView *)trashIcon {
//    if (!_trashIcon) {
//        _trashIcon = ({
//            UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_n"]];
//            imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_h"];
//            imageView;
//        });
//    }
//    return _trashIcon;
//}

- (UIImageView *)animatedImage {
    if (!_animatedImage) {
        _animatedImage = ({
            UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@""]];
            imageView;
        });
    }
    return _animatedImage;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
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
            [button addTarget:self action:@selector(sendRecord:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"发送" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
            
            [self addSubview:button];
            button;
        });
    }
    return _sendBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = ({
            UILabel * label = [[UILabel alloc] init];
            [self addSubview:label];
            label;
        });
    }
    return _timeLabel;
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    _recordBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"按住说话" forState:UIControlStateNormal];
//        [button setTitle:@"松开发送" forState:UIControlStateSelected | UIControlStateHighlighted];
//        [button setTitle:@"松开发送" forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor ctmsg_color7F7F7F] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(recordTouched:) forControlEvents:UIControlEventTouchDown];
//        [button addTarget:self action:@selector(recordEnded:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_n"] forState:UIControlStateNormal];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_s"] forState:UIControlStateSelected | UIControlStateHighlighted];
//        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_s"] forState:UIControlStateHighlighted];
        
        CGFloat imageWidth = 101;
        CGFloat spacing = 10;
        CGFloat textWidth = _recordBtn.titleLabel.intrinsicContentSize.width;
        CGFloat textHeight = _recordBtn.titleLabel.intrinsicContentSize.height;
        button.imageEdgeInsets = UIEdgeInsetsMake(textHeight + spacing, 0, 0, -textWidth);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, imageWidth + spacing, 0);
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(voiceBtnPan:)];
        [button addGestureRecognizer:pan];
        [self addSubview:button];
        button;
    });
    
    _playIcon = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_n"]];
        imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_h"];
        imageView.hidden = YES;
        [self addSubview:imageView];
        imageView;
    });
    
    _trashIcon = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_n"]];
        imageView.highlightedImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_del_h"];
        imageView.hidden = YES;
        [self addSubview:imageView];
        imageView;
    });
}

@end
