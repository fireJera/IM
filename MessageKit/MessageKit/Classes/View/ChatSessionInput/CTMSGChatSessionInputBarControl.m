//
//  CTMSGChatSessionInputBarControl.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatSessionInputBarControl.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGChatVoiceInputView.h"
#import "CTMSGChatAlbumPickView.h"
#import "CTMSGEmojiBoardView.h"
#import "CTMSGUtilities.h"
#import "CTMSGChatCameraViewController.h"
#import "CTMSGAlbumListViewController.h"
#import "CTMSGAudioRecordTool.h"
//#import "CTMSGAMRDataConverter.h"

@interface CTMSGChatSessionInputBarControl () <CTMSGEmojiViewDelegate, UITextViewDelegate
, CTMSGChatVoiceInputViewDelegate, CTMSGChatAlbumPickViewDelegate> {
    NSMutableArray<UIButton *> * _buttons;
    CGFloat _inputTextHeight;
}

@end

@implementation CTMSGChatSessionInputBarControl

#pragma mark - setview

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_ctmsg_setFrame];
}

#pragma mark - CTMSGChatVoiceInputViewDelegate

- (void)voiceReocordStart:(CTMSGChatVoiceInputView *)inputView {
    if ([_delegate respondsToSelector:@selector(recordDidBegin)]) {
        [_delegate recordDidBegin];
    }
}

- (void)voiceReocordCancel:(CTMSGChatVoiceInputView *)inputView {
    BOOL isTooShort = inputView.recordTooShort;
    if ([_delegate respondsToSelector:@selector(recordDidCancel:)]) {
        [_delegate recordDidCancel:isTooShort];
    }
}

- (void)voiceReocordEndAndSend:(CTMSGChatVoiceInputView *)inputView {
    if ([_delegate respondsToSelector:@selector(recordDidEnd:recordPath:duration:error:)]) {
        NSString *wavPath = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
//        NSString *path = [CTMSGAudioRecordTool shareRecorder].audioRecordCompressPath;
//        [[CTMSGAMRDataConverter sharedAMRDataConverter] convertWavToAmr:wavPath amrSavePath:path];

        NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:wavPath] options:opts]; // 初始化视频媒体文件
        NSUInteger second = 0;
        second = ceil(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒
        second = MAX(1, second);
        NSData * wavData = [NSData dataWithContentsOfFile:wavPath];
//        NSData * data = [NSData dataWithContentsOfFile:path];
        [_delegate recordDidEnd:wavData recordPath:wavPath duration:second error:nil];
    }
}

#pragma mark - CTMSGChatAlbumPickViewDelegate

- (void)sendImages:(NSArray<UIImage *> *)images {
    if ([_delegate respondsToSelector:@selector(pickImages:)]) {
        [_delegate pickImages:images];
    }
}

- (void)pickViewClickOpenAlbum {
    self.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
    [self openAlbumController];
}

- (void)pickNumBeyondMax {
    [_delegate pickNumBeyondMax];
}

#pragma mark - CTMSGEmojiViewDelegate

- (void)didTouchEmojiView:(CTMSGEmojiBoardView *)emojiView touchedEmoji:(NSString *)string {
    if ([_delegate respondsToSelector:@selector(emojiView:didTouchedEmoji:)]) {
        [_delegate emojiView:emojiView didTouchedEmoji:string];
    }
    [self textViewDidChange:_inputTextView];
    [emojiView enableSendButton:YES];
}

- (void)didSendButtonEvent:(CTMSGEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton {
    if ([_delegate respondsToSelector:@selector(emojiView:didTouchSendButton:)]) {
        [_delegate emojiView:emojiView didTouchSendButton:sendButton];
    }
    [self textViewDidChange:_inputTextView];
    [emojiView enableSendButton:NO];
}

- (void)didRemoveEmojiView:(CTMSGEmojiBoardView *)emojiView {
    if ([_delegate respondsToSelector:@selector(emojiViewRemoveEmoji:)]) {
        [_delegate emojiViewRemoveEmoji:emojiView];
    }
    [self textViewDidChange:_inputTextView];
    if (_inputTextView.text.length == 0) {
        [emojiView enableSendButton:NO];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.currentBottomBarStatus = CTMSGBottomInputBarKeyboardStatus;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] ) {
        if (textView.text.length > 0) {
            if ([_delegate respondsToSelector:@selector(inputTextViewDidTouchSendKey:)]) {
                [_delegate inputTextViewDidTouchSendKey:textView];
            }
            return NO;
//            self.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
        } else {
            return NO;
        }
    } else {
        if ([_delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
            [_delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect frame = [self p_ctmsg_getFrame];
    if ([_delegate respondsToSelector:@selector(chatInputBar:shouldChangeFrame:)]) {
        [_delegate chatInputBar:self shouldChangeFrame:frame];
    }
}

#pragma mark - touch event

- (void)clickVoice:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.voiceRecordView.hidden = NO;
    }
    self.currentBottomBarStatus = sender.selected ? CTMSGBottomInputBarVoiceStatus : CTMSGBottomInputBarDefaultStatus;
}

- (void)clickAlbum:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.albumPickView.hidden = NO;
    }
    self.currentBottomBarStatus = sender.selected ? CTMSGBottomInputBarAlbumStatus : CTMSGBottomInputBarDefaultStatus;
}

- (void)clickCamera:(UIButton *)sender {
    sender.selected = NO;
    self.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
    [self openCameraController];
}

- (void)clickEmoji:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.emojiBoardView.hidden = NO;
    }
    self.currentBottomBarStatus = sender.selected ? CTMSGBottomInputBarEmojiStatus : CTMSGBottomInputBarDefaultStatus;
}

- (void)clickPlugin:(UIButton *)sender {
    
}

#pragma mark - public

- (void)cancelVoiceRecord {
    if ([_delegate respondsToSelector:@selector(recordDidCancel:)]) {
        [_delegate recordDidCancel:NO];
    }
}

- (void)endVoiceRecord {
    
}

//- (void)containerViewWillAppear {
//
//}
//
//- (void)containerViewDidAppear {
//
//}
//
//- (void)containerViewWillDisappear {
//
//}

- (void)updateStatus:(CTMSGBottomInputBarStatus)status animated:(BOOL)animated {
    self.currentBottomBarStatus = status;
}

- (void)resetToDefaultStatus {
    self.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
}

//- (void)containerViewSizeChanged {
//    [self textViewDidChange:_inputTextView];
//}

- (void)openAlbumController {
    if ([_delegate respondsToSelector:@selector(presentViewController:functionTag:)]) {
        CTMSGAlbumListViewController *album = [[CTMSGAlbumListViewController alloc] init];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:album];
        [_delegate presentViewController:nav functionTag:CTMSG_InputBarAlbum];
    }
}

- (void)openCameraController {
    CTMSGChatCameraViewController * camera = [[CTMSGChatCameraViewController alloc] init];
    if ([_delegate respondsToSelector:@selector(presentViewController:functionTag:)]) {
        [_delegate presentViewController:camera functionTag:CTMSG_InputBarCamera];
    }
}

#pragma mark - private

- (void)p_ctmsg_setFrame {
    CGFloat selfWidth = self.frame.size.width, btnHeight = 40;
    CGFloat topHeight = CTMSGInputNormalHeight + _inputTextHeight - kInputTextViewNormalHeight;
    _inputContainerView.frame = (CGRect){0, 0, selfWidth, topHeight};
    CGFloat inputLeft = 10, inputTop = 6, inputHeight = _inputContainerView.frame.size.height - btnHeight - inputTop;
    CGFloat inputWith = self.frame.size.width - inputLeft * 2;
    _inputTextView.frame = (CGRect){inputLeft, inputTop, inputWith, inputHeight};
    CGFloat btnWidth = selfWidth / _buttons.count;
    CGFloat btnTop = inputTop + inputHeight;
    [_buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = (CGRect){btnWidth * idx, btnTop, btnWidth, btnHeight};
    }];
    
    CGFloat bottomTop = _inputContainerView.frame.size.height;
    if (_bottomContainerView) {
        _bottomContainerView.frame = (CGRect){0, bottomTop, selfWidth, CTMSGInputBottomHeight};
    }
    if (_voiceRecordView) {
        _voiceRecordView.frame = _bottomContainerView.bounds;
    }
    if (_albumPickView) {
        _albumPickView.frame = _bottomContainerView.bounds;
    }
    if (_emojiBoardView) {
        _emojiBoardView.frame = _bottomContainerView.bounds;
    }
    if (_lockView) {
        _lockView.frame = _inputContainerView.bounds;
    }
}

- (CGRect)p_ctmsg_getFrame {
    if (_inputTextView.text.length > 0) {
        CGSize constraintSize = _inputTextView.frame.size;
        constraintSize.width = MAX(constraintSize.width, CGFLOAT_MAX);
        CGSize size = [_inputTextView sizeThatFits:constraintSize];
        size.height = MAX(size.height, kInputTextViewNormalHeight);
        _inputTextHeight = size.height;
    } else {
        _inputTextHeight = kInputTextViewNormalHeight;
    }
    CGFloat topHeight = CTMSGInputNormalHeight + _inputTextHeight - kInputTextViewNormalHeight;
    CGFloat bottomHeight;
    switch (_currentBottomBarStatus) {
        case CTMSGBottomInputBarDefaultStatus:
        case CTMSGBottomInputBarLockStatus:
            bottomHeight = 0;
            break;
        case CTMSGBottomInputBarKeyboardStatus:
            bottomHeight = _keyboardHeight;
            break;
        case CTMSGBottomInputBarVoiceStatus:
        case CTMSGBottomInputBarAlbumStatus:
        case CTMSGBottomInputBarEmojiStatus:
            bottomHeight = CTMSGInputBottomHeight;
            break;
    }
    CGFloat selfHeight = topHeight + bottomHeight;
    CGFloat top = _containerView.frame.size.height - selfHeight - CTMSGIphoneXBottomH;
    CGRect frame = (CGRect){0, top, _containerView.frame.size.width, selfHeight};
    return frame;
}

#pragma mark - setter

- (void)setCurrentBottomBarStatus:(CTMSGBottomInputBarStatus)currentBottomBarStatus {
    _currentBottomBarStatus = currentBottomBarStatus;
    if (currentBottomBarStatus != CTMSGBottomInputBarKeyboardStatus) [_inputTextView resignFirstResponder];
    _voiceButton.selected = currentBottomBarStatus == CTMSGBottomInputBarVoiceStatus;
    _voiceRecordView.hidden = currentBottomBarStatus != CTMSGBottomInputBarVoiceStatus;;
    
    _albumButton.selected = currentBottomBarStatus == CTMSGBottomInputBarAlbumStatus;
    _albumPickView.hidden = currentBottomBarStatus != CTMSGBottomInputBarAlbumStatus;
    
    _emojiButton.selected = currentBottomBarStatus == CTMSGBottomInputBarEmojiStatus;
    _emojiBoardView.hidden = currentBottomBarStatus != CTMSGBottomInputBarEmojiStatus;
    _bottomContainerView.backgroundColor = currentBottomBarStatus == CTMSGBottomInputBarDefaultStatus ? [UIColor ctmsg_colorF4F5F8] : [UIColor whiteColor];
    if (currentBottomBarStatus == CTMSGBottomInputBarLockStatus) {
//        _lockView.frame = _inputContainerView.bounds;
//        [_inputContainerView addSubview:_lockView];
        [self addSubview:self.lockEffectView];
        [self bringSubviewToFront:_lockEffectView];
        _lockView.frame = self.bounds;
        [_lockView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame = _lockView.bounds;
        }];
        [self bringSubviewToFront:_lockView];
    } else {
        [_lockView removeFromSuperview];
        [_lockEffectView removeFromSuperview];
    }
    CGRect frame = [self p_ctmsg_getFrame];
    if ([_delegate respondsToSelector:@selector(chatInputBar:shouldChangeFrame:)]) {
        [_delegate chatInputBar:self shouldChangeFrame:frame];
    }
}

#pragma mark - lazy

//- (UIVisualEffectView *)lockView {
//    if (!_lockView) {
//        _lockView = ({
//            UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
//            effectView.frame = self.bounds;
//            effectView.alpha = 0.9;
//            [self addSubview:effectView];
//            [self sendSubviewToBack:effectView];
//            effectView;
//        });
//        _lockLabel = ({
//            UILabel * label = [[UILabel alloc] init];
//            label.numberOfLines = 0;
//            label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
//            label.textColor = [UIColor whiteColor];
//            label;
//        });
//    }
//    return _lockView;
//}

- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        [self addSubview:_bottomContainerView];
    }
    return _bottomContainerView;
}

- (CTMSGChatVoiceInputView *)voiceRecordView {
    if (!_voiceRecordView) {
        _voiceRecordView = [[CTMSGChatVoiceInputView alloc] init];
        [self.bottomContainerView addSubview:_voiceRecordView];
        _voiceRecordView.delegate = self;
    }
    return _voiceRecordView;
}

- (CTMSGChatAlbumPickView *)albumPickView {
    if (!_albumPickView) {
        _albumPickView = [[CTMSGChatAlbumPickView alloc] init];
        [self.bottomContainerView addSubview:_albumPickView];
        _albumPickView.delegate = self;
    }
    return _albumPickView;
}

- (CTMSGEmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView = [[CTMSGEmojiBoardView alloc] init];
        [self.bottomContainerView addSubview:_emojiBoardView];
        _emojiBoardView.delegate = self;
    }
    return _emojiBoardView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
            withContainerView:(UIView *)containerView {
//                  controlType:(CTMSGChatSessionInputBarControlType)controlType {
    self = [super initWithFrame:frame];
    if (self) {
        _containerView = containerView;
        [self p_commonInit];
    }
    return self;
}

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
    _buttons = [NSMutableArray array];
    _inputTextHeight = kInputTextViewNormalHeight;
    _inputContainerView = [[UIView alloc] init];
    _inputContainerView.backgroundColor = [UIColor ctmsg_colorF4F5F8];
    [self addSubview:_inputContainerView];
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.delegate = self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.layer.cornerRadius = 4;
    _inputTextView.textColor = [UIColor ctmsg_color212121];
    [_inputContainerView addSubview:_inputTextView];
    _voiceButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(clickVoice:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_small_n"] forState:UIControlStateNormal];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_small_s"] forState:UIControlStateSelected];
        [_inputContainerView addSubview:button];
        [_buttons addObject:button];
        button;
    });
    _albumButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(clickAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_album_n"] forState:UIControlStateNormal];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_album_s"] forState:UIControlStateSelected];
        [_inputContainerView addSubview:button];
        [_buttons addObject:button];
        button;
    });
    _cameraButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(clickCamera:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_camera_n"] forState:UIControlStateNormal];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_camera_s"] forState:UIControlStateSelected];
        [_inputContainerView addSubview:button];
        [_buttons addObject:button];
        button;
    });
    _emojiButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(clickEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_emoji_n"] forState:UIControlStateNormal];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_emoji_s"] forState:UIControlStateSelected];
        [_inputContainerView addSubview:button];
        [_buttons addObject:button];
        button;
    });
}

- (UIVisualEffectView *)lockEffectView {
    if (!_lockEffectView) {
        _lockEffectView = ({
            UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
            effectView.alpha = 0.9;
            effectView.frame = self.bounds;
            effectView;
        });
    }
    return _lockEffectView;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
