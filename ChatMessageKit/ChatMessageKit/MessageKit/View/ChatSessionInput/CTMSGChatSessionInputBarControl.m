//
//  CTMSGChatSessionInputBarControl.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatSessionInputBarControl.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"
#import "CTMSGChatVoiceInputView.h"
#import "CTMSGChatAlbumPickView.h"
#import "CTMSGEmojiBoardView.h"
#import "CTMSGUtilities.h"
#import "CTMSGChatCameraViewController.h"
#import "CTMSGAudioRecordTool.h"
#import "CTMSGAMRDataConverter.h"

const CGFloat CTMSGInputNormalHeight = 84;
//const CGFloat CTMSGInputEmojiHeight = 200;
const CGFloat CTMSGInputEditingHeight = 304;
static const int kNormalInputTextHeight = 38;

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
    CGFloat selfWidth = self.frame.size.width, btnHeight = 40;
    _inputContainerView.frame = (CGRect){0, 0, selfWidth, CTMSGInputNormalHeight + _inputTextHeight - kNormalInputTextHeight};
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
        _bottomContainerView.frame = (CGRect){0, bottomTop, selfWidth, CTMSGInputEditingHeight - CTMSGInputNormalHeight};
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
        _voiceRecordView.frame = _inputContainerView.bounds;
    }
}

#pragma mark - CTMSGChatVoiceInputViewDelegate

- (void)voiceReocordStart:(CTMSGChatVoiceInputView *)inputView {
    if ([_delegate respondsToSelector:@selector(recordDidBegin)]) {
        [_delegate recordDidBegin];
    }
}

- (void)voiceReocordCancel:(CTMSGChatVoiceInputView *)inputView {
    if ([_delegate respondsToSelector:@selector(recordDidCancel)]) {
        [_delegate recordDidCancel];
    }
}

- (void)voiceReocordEndAndSend:(CTMSGChatVoiceInputView *)inputView {
    if ([_delegate respondsToSelector:@selector(recordDidEnd:recordPath:duration:error:)]) {
        NSString *wavPath = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
        NSString *path = [CTMSGAudioRecordTool shareRecorder].audioRecordCompressPath;
        [[CTMSGAMRDataConverter sharedAMRDataConverter] convertWavToAmr:wavPath amrSavePath:path];

        NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:wavPath] options:opts]; // 初始化视频媒体文件
        NSUInteger second = 0;
        second = ceil(urlAsset.duration.value / urlAsset.duration.timescale); // 获取视频总时长,单位秒
        second = MAX(1, second);
        NSData * wavData = [NSData dataWithContentsOfFile:wavPath];
        NSData * data = [NSData dataWithContentsOfFile:path];
        [_delegate recordDidEnd:wavData recordPath:wavPath duration:second error:nil];
    }
}

#pragma mark - CTMSGChatAlbumPickViewDelegate

- (void)sendImages:(NSArray<UIImage *> *)images {
    if ([_delegate respondsToSelector:@selector(pickImages:)]) {
        [_delegate pickImages:images];
    }
}

#pragma mark - CTMSGEmojiViewDelegate

- (void)didTouchEmojiView:(CTMSGEmojiBoardView *)emojiView touchedEmoji:(NSString *)string {
    if ([_delegate respondsToSelector:@selector(emojiView:didTouchedEmoji:)]) {
        [_delegate emojiView:emojiView didTouchedEmoji:string];
    }
}

- (void)didSendButtonEvent:(CTMSGEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton {
    if ([_delegate respondsToSelector:@selector(emojiView:didTouchSendButton:)]) {
        [_delegate emojiView:emojiView didTouchSendButton:sendButton];
    }
}

- (void)didRemoveEmojiView:(CTMSGEmojiBoardView *)emojiView {
    if ([_delegate respondsToSelector:@selector(emojiViewRemoveEmoji:)]) {
        [_delegate emojiViewRemoveEmoji:emojiView];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _currentBottomBarStatus = KBottomBarKeyboardStatus;
    [self p_ctmsg_resetView:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] ) {
        if (textView.text.length > 0) {
            if ([_delegate respondsToSelector:@selector(inputTextViewDidTouchSendKey:)]) {
                [_delegate inputTextViewDidTouchSendKey:textView];
            }
            [textView resignFirstResponder];
            _currentBottomBarStatus = KBottomBarDefaultStatus;
            [self p_ctmsg_resetView:YES];
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
    CGSize constraintSize = textView.frame.size;
    constraintSize.height = MAX(constraintSize.height, kNormalInputTextHeight);
    _inputTextHeight = constraintSize.height;
    CGSize size = [textView sizeThatFits:constraintSize];
    size.height = MAX(size.height, kNormalInputTextHeight);
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, size.height);
    if ([_delegate respondsToSelector:@selector(chatInputBar:shouldChangeFrame:)]) {
        [_delegate chatInputBar:self shouldChangeFrame:CGRectZero];
    }
}

#pragma mark - touch event

- (void)clickVoice:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_inputTextView resignFirstResponder];
    _currentBottomBarStatus = sender.selected ? KBottomBarVoiceStatus : KBottomBarDefaultStatus;
    if (sender.selected) {
        [self.bottomContainerView addSubview:self.voiceRecordView];
    }
    [self p_ctmsg_resetView:YES];
    [self setNeedsLayout];
}

- (void)clickAlbum:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_inputTextView resignFirstResponder];
    _currentBottomBarStatus = sender.selected ? KBottomBarAlbumStatus : KBottomBarDefaultStatus;
    if (sender.selected) {
        [self.bottomContainerView addSubview:self.albumPickView];
    }
    [self p_ctmsg_resetView:YES];
    [self setNeedsLayout];
}

- (void)clickCamera:(UIButton *)sender {
    sender.selected = NO;
    [_inputTextView resignFirstResponder];
    _currentBottomBarStatus = KBottomBarDefaultStatus;
    [self p_ctmsg_resetView:YES];
    [self openCameraController];
}

- (void)clickEmoji:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_inputTextView resignFirstResponder];
    _currentBottomBarStatus = sender.selected ? KBottomBarEmojiStatus : KBottomBarDefaultStatus;
    if (sender.selected) {
        [self.bottomContainerView addSubview:self.emojiBoardView];
    }
    [self p_ctmsg_resetView:YES];
    [self setNeedsLayout];
}

- (void)clickPlugin:(UIButton *)sender {
    
}

#pragma mark - notification

#pragma mark - public

- (void)cancelVoiceRecord {
    if ([_delegate respondsToSelector:@selector(recordDidCancel)]) {
        [_delegate recordDidCancel];
    }
}

- (void)endVoiceRecord {
    
}

- (void)containerViewWillAppear {
    
}

- (void)containerViewDidAppear {
    
}

- (void)containerViewWillDisappear {
    
}

- (void)updateStatus:(KBottomBarStatus)status animated:(BOOL)animated {
    _currentBottomBarStatus = status;
    [self p_ctmsg_resetView:animated];
}

- (void)resetToDefaultStatus {
    _currentBottomBarStatus = KBottomBarDefaultStatus;
    [self p_ctmsg_resetView:YES];
}

- (void)containerViewSizeChanged {
    [self textViewDidChange:_inputTextView];
}

- (void)setDefaultInputType:(CTMSGChatSessionInputBarInputType)defaultInputType {
    _defaultInputType = defaultInputType;
    switch (_defaultInputType) {
        case CTMSGChatSessionInputBarInputTypeText:
            
            break;
        case CTMSGChatSessionInputBarInputTypeVoice:
            [self clickAlbum:_voiceButton];
            break;
        case CTMSGChatSessionInputBarInputTypeAlbum:
            [self clickAlbum:_albumButton];
            break;
        case CTMSGChatSessionInputBarInputTypeCamera:
            [self clickAlbum:_cameraButton];
            break;
        case CTMSGChatSessionInputBarInputTypeEmoji:
            [self clickAlbum:_emojiButton];
            break;
        case CTMSGChatSessionInputBarInputTypeExtention:
//            [self clickAlbum:_additionalButton];
            break;
    }
}

- (void)openAlbumController {
    if ([_delegate respondsToSelector:@selector(presentViewController:functionTag:)]) {
        [_delegate presentViewController:[[UIViewController alloc] init] functionTag:CTMSG_InputBarAlbum];
    }
}

- (void)openCameraController {
    CTMSGChatCameraViewController * camera = [[CTMSGChatCameraViewController alloc] init];
    if ([_delegate respondsToSelector:@selector(presentViewController:functionTag:)]) {
        [_delegate presentViewController:camera functionTag:CTMSG_InputBarCamera];
    }
}

#pragma mark - private
// 改变自身frame 逻辑 文字输入改变是通过代理的回调方法让containerView来改变的
// 而点击输入框下方按钮是通过此方法来处理的
// 输入框弹起通过ViewController的通知来实现的
// 输入框收起 一种是回车: self UItextVIewDelegate)
// 一种是点击按钮: 下方方法
// 还有点击collectionView: UIViewController scrollViewDelegate
- (void)p_ctmsg_resetView:(BOOL)animated {
    _voiceButton.selected = NO;
    _cameraButton.selected = NO;
    _albumButton.selected = NO;
    _emojiButton.selected = NO;
    _voiceRecordView.hidden = YES;
    _albumPickView.hidden = YES;
    _emojiBoardView.hidden = YES;
    CGFloat height = CTMSGInputEditingHeight;
    switch (_currentBottomBarStatus) {
        case KBottomBarDefaultStatus:
            height = CTMSGInputNormalHeight;
            break;
        case KBottomBarKeyboardStatus:
            break;
        case KBottomBarLockStatus:
            height = CTMSGInputNormalHeight;
            break;
        case KBottomBarVoiceStatus:
            _voiceRecordView.hidden = NO;
            _voiceButton.selected = YES;
            break;
        case KBottomBarAlbumStatus:
            _albumPickView.hidden = NO;
            _albumButton.selected = YES;
            break;
        case KBottomBarCameraStatus:
            _voiceRecordView.hidden = NO;
            _cameraButton.selected = YES;
            break;
        case KBottomBarEmojiStatus:
            _emojiBoardView.hidden = NO;
            _emojiButton.selected = YES;
            break;
        case KBottomBarPluginStatus:
//            _voiceRecordView.hidden = NO;
//            _voiceButton.selected = YES;
            break;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = frame;
        }];
    } else {
        self.frame = frame;
    }
    if ([_delegate respondsToSelector:@selector(chatSessionInputBarStatusChanged:)]) {
        [_delegate chatSessionInputBarStatusChanged:_currentBottomBarStatus];
    }
}

#pragma mark - setter

- (void)setInputBarType:(CTMSGChatSessionInputBarControlType)inputBarType {
    _inputBarType = inputBarType;
}

#pragma mark - getter

- (CGFloat)height {
    CGFloat topHeight = _inputTextHeight - kNormalInputTextHeight + CTMSGInputNormalHeight;
    CGFloat bottomHeight = CTMSGInputEditingHeight - CTMSGInputNormalHeight;
    switch (_currentBottomBarStatus) {
        case KBottomBarDefaultStatus:
            bottomHeight = 0;
            break;
        case KBottomBarKeyboardStatus:
            bottomHeight = _keyboardHeight;
            break;
        default:
            break;
    }
    return topHeight + bottomHeight;
}

#pragma mark - lazy

- (UIVisualEffectView *)lockView {
    if (!_lockView) {
        _lockView = ({
            UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
            effectView.frame = self.bounds;
            effectView.alpha = 0.9;
            [self addSubview:effectView];
            [self sendSubviewToBack:effectView];
            effectView;
        });
        _lockLabel = ({
            UILabel * label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.font = [UIFont ctmsg_PingFangMedium16];
            label.textColor = [UIColor whiteColor];
//            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _lockView;
}

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
        _voiceRecordView.delegate = self;
//        _voiceRecordView.delegate = self;
    }
    return _voiceRecordView;
}

- (CTMSGChatAlbumPickView *)albumPickView {
    if (!_albumPickView) {
        _albumPickView = [[CTMSGChatAlbumPickView alloc] init];
        _albumPickView.delegate = self;
//        _albumPickView.delegate = self;
    }
    return _albumPickView;
}

- (CTMSGEmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView = [[CTMSGEmojiBoardView alloc] init];
        _emojiBoardView.delegate = self;
    }
    return _emojiBoardView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
            withContainerView:(UIView *)containerView
                  controlType:(CTMSGChatSessionInputBarControlType)controlType
             defaultInputType:(CTMSGChatSessionInputBarInputType)defaultInputType {
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    _buttons = [NSMutableArray array];
    _inputTextHeight = kNormalInputTextHeight;
    _inputContainerView = [[UIView alloc] init];
    _inputContainerView.backgroundColor = [UIColor ctmsg_colorF4F5F8];
    [self addSubview:_inputContainerView];
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.delegate = self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.layer.cornerRadius = 5;
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
//    _voiceButton = ({
//        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self action:@selector(clickVoice:) forControlEvents:UIControlEventTouchUpInside];
//        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_camera_n"] forState:UIControlStateNormal];
//        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_emoji_s"] forState:UIControlStateSelected];
//        [_inputContainerView addSubview:button];
//        button;
//    });
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
