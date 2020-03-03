//
//  CTMSGVoiceMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGVoiceMessageCell.h"
#import "CTMSGMessageModel.h"
//#import "CTMSGVoiceMessage.h"
#import <MessageLib/MessageLib-umbrella.h>
//#import <MessageLib/CTMSGVoiceMessage.h>
//#import <MessageLib/CTMSGDataBaseManager.h>
#import "CTMSGContentView.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import "CTMSGAudioRecordTool.h"
#import "CTMSGAMRDataConverter.h"
#import "CTMSGIM.h"

#if __has_include (<YYCache/YYCache.h>)
#import <YYCache/YYCache.h>
#else
#import "YYCache/YYCache.h"
#endif

NSString *const kNotificationPlayVoice = @"kNotificationPlayVoice";
NSString *const kNotificationStopVoicePlayer = @"kNotificationStopVoicePlayer";

const int CTMSGVoiceMessageImageRight = 12;
const int CTMSGVoiceMessageTextRight = 4;

@interface CTMSGVoiceMessageCell () <AVAudioPlayerDelegate> {
    NSArray<UIImage *> * _fromImages;
    NSArray<UIImage *> * _toImages;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation CTMSGVoiceMessageCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CTMSGVoiceMessage *message = (CTMSGVoiceMessage *)model.content;
    CGSize size = [self getBubbleBackgroundViewSize:message];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
    return (CGSize){collectionViewWidth, extraHeight};
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [_audioPlayer stop];
    [self p_ctmsg_updateCell];
    [self updateStatusContentView:model];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
        CTMSGVoiceMessage * message = (CTMSGVoiceMessage *)self.model.content;
        _voiceDurationLabel.text = [NSString stringWithFormat:@"%ld", message.duration];
        [self p_ctmsg_updateFrame];
    }
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGVoiceMessage * message = (CTMSGVoiceMessage *)self.model.content;
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleBackgroundViewSize:message];
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage * bubbleImage = nil, *voiceImage = nil;
    self.bubbleBackgroundView.frame = (CGRect){CGPointZero, bubbleBackgroundViewSize};
    _voiceUnreadTagView.hidden = YES;
    //拉伸图片
    if (self.messageDirection == CTMSGMessageDirectionReceive) {
        _voiceDurationLabel.textColor = [UIColor whiteColor];
        messageContentViewRect.origin.x = CTMSGMessageCellBubbleLeading + CTMSGMessageCellAvatarWith + CTMSGMessageCellAvatarLeading;
        messageContentViewRect.size = bubbleBackgroundViewSize;
        bubbleImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_to"];
        voiceImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_to_voice_msg_1"];
        
        _playVoiceView.image = _toImages.firstObject;
        _playVoiceView.animationImages = _toImages;
        if (self.model.receivedStatus != ReceivedStatus_LISTENED) {
            self.voiceUnreadTagView.hidden = NO;
        }
    } else {
        _voiceDurationLabel.textColor = [UIColor ctmsg_color212121];
        messageContentViewRect.size = bubbleBackgroundViewSize;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading) - CTMSGMessageCellAvatarWith - CTMSGMessageCellAvatarLeading;
        bubbleImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_from"];
        voiceImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_from_voice_msg_1"];
        
        _playVoiceView.image = _fromImages.firstObject;
        _playVoiceView.animationImages = _fromImages;
    }
    _voiceDurationLabel.text = [NSString stringWithFormat:@"%ld″", message.duration];
    [_voiceDurationLabel sizeToFit];
    _playVoiceView.image = voiceImage;
    CGFloat imageLeft = messageContentViewRect.size.width - voiceImage.size.width - CTMSGVoiceMessageImageRight;
    CGFloat imageTop = (messageContentViewRect.size.height - voiceImage.size.height) / 2;
    _playVoiceView.frame = (CGRect){imageLeft, imageTop, voiceImage.size};
    CGFloat textLeft = imageLeft - _voiceDurationLabel.frame.size.width - CTMSGVoiceMessageTextRight;
    CGFloat textTop = (messageContentViewRect.size.height - _voiceDurationLabel.frame.size.height) / 2;
    _voiceDurationLabel.frame = (CGRect){textLeft, textTop, _voiceDurationLabel.frame.size};
    self.messageContentView.frame = messageContentViewRect;
    _voiceUnreadTagView.frame = (CGRect){messageContentViewRect.size.width + 4, 2, _voiceUnreadTagView.frame.size};
    self.bubbleBackgroundView.image = [bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.3, bubbleImage.size.width * 0.3,
                                                                                          bubbleImage.size.height * 0.7, bubbleImage.size.width * 0.7)];
}

- (void)updateStatusContentView:(CTMSGMessageModel *)model {
    [super updateStatusContentView:model];
    [self.messageActivityIndicatorView stopAnimating];
    if (model.sentStatus == SentStatus_SENDING) {
        self.messageActivityIndicatorView.hidden = NO;
        [self.messageActivityIndicatorView startAnimating];
        self.messageFailedStatusView.hidden = YES;
    }
    else if (model.sentStatus == SentStatus_FAILED) {
        self.messageActivityIndicatorView.hidden = YES;
        self.messageFailedStatusView.hidden = NO;
    }
    else if (model.sentStatus == SentStatus_SENT) {
        self.messageActivityIndicatorView.hidden = YES;
        self.messageFailedStatusView.hidden = YES;
        return;
    }
    if (model.messageDirection == CTMSGMessageDirectionSend) {
        CGFloat failedLeft = self.messageContentView.frame.origin.x - 10 - self.messageFailedStatusView.frame.size.width;
        CGFloat failedTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - self.messageFailedStatusView.frame.size.height) / 2);
        self.messageFailedStatusView.frame = CGRectMake(failedLeft, failedTop, self.messageFailedStatusView.frame.size.width, self.messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiLeft = self.messageContentView.frame.origin.x - 10 - indiWidth;
        CGFloat indiTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - indiWidth) / 2);
        self.messageActivityIndicatorView.frame = CGRectMake(indiLeft, indiTop, indiWidth, indiWidth);
    }
    else {
        CGFloat left = self.messageContentView.frame.origin.x + self.messageContentView.frame.size.width + 10;
        CGFloat failedTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - self.messageFailedStatusView.frame.size.height) / 2);
        self.messageFailedStatusView.frame = CGRectMake(left, failedTop, self.messageFailedStatusView.frame.size.width, self.messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - indiWidth) / 2);
        self.messageActivityIndicatorView.frame = CGRectMake(left, indiTop, indiWidth, indiWidth);
    }
}

#pragma mark - touch event
- (void)tapVoice:(UIGestureRecognizer *)gestureRecognizer {
    [self playVoice];
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

#pragma mark - notification

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    [super messageCellUpdateSendingStatusEvent:notification];
    NSDictionary * dic = notification.object;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        long messageId = [dic[@"messageId"] longValue];
        CTMSGSentStatus status = [dic[@"status"] unsignedIntegerValue];
        if (self.model.messageId == messageId) {
            self.model.sentStatus = status;
            [self updateStatusContentView:self.model];
        }
    }
}

#pragma mark - public

- (void)playVoice {
    self.model.receivedStatus = ReceivedStatus_LISTENED;
    [[CTMSGDataBaseManager shareInstance] updateSingleMessageListenedWithMessageId:@(self.model.messageId).stringValue];
    self.voiceUnreadTagView.hidden = YES;
    if (_audioPlayer.playing) {
        [self stopPlayVoice];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayVoice object:nil];
    CTMSGVoiceMessage * message = (CTMSGVoiceMessage *)self.model.content;
    NSData * data = message.wavAudioData;
//    NSString * wavPath = [CTMSGAudioRecordTool shareRecorder].playWAVPath;
//    NSString * amrPath = [CTMSGAudioRecordTool shareRecorder].playAMRPath;
//    [data writeToFile:amrPath atomically:YES];
//    [[CTMSGAMRDataConverter sharedAMRDataConverter] convertAmrToWav:amrPath wavSavePath:wavPath];
    NSError * error;
//    NSURL * url = [NSURL fileURLWithPath:wavPath];
    if (!data) {
        if (message.localURL) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:message.localURL]) {
                data = [NSData dataWithContentsOfFile:message.localURL];
            }
        }
    }
    if (!data) {
        YYCache * cache = [YYCache cacheWithName:[CTMSGIM sharedCTMSGIM].currentUserInfo.userId];
        id<NSCoding> cacheData = [cache objectForKey:message.wavURL];
        if (!cacheData) {
            cacheData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.wavURL]];
            [cache setObject:cacheData forKey:message.wavURL];
        }
        data = (NSData *)cacheData;
    }
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (!error) {
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        _audioPlayer.delegate = self;
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        [_playVoiceView startAnimating];
    } else {
        
    }
}

- (void)stopPlayVoice {
    [_audioPlayer stop];
    [_playVoiceView stopAnimating];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_playVoiceView stopAnimating];
    if (flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStopVoicePlayer object:self.model];
    }
}

#pragma mark - private

+ (CGSize)getBubbleSize:(float)duration {
    CGSize bubbleSize = CGSizeMake(CTMSGMessageCellBubbleMinWidth + 16 + duration * 0.8, CTMSGMessageCellBubbleMinHeight);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CTMSGVoiceMessage *)message {
    return [[self class] getBubbleSize:message.duration];
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self p_ctmsg_initView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_ctmsg_initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self p_ctmsg_initView];
}

- (void)p_ctmsg_initView {
    _playVoiceView = [[UIImageView alloc] init];
    [self.bubbleBackgroundView addSubview:_playVoiceView];
    _voiceDurationLabel = [[UILabel alloc] init];
    [self.messageContentView addSubview:_voiceDurationLabel];
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *voiceTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoice:)];
    voiceTap.numberOfTapsRequired = 1;
    voiceTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:voiceTap];
    _playVoiceView.animationDuration = 0.8;
    NSString * imageName = @"ctmsg_chat_to_voice_msg_";
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 1; i < 4; i++) {
        NSString * name = [NSString stringWithFormat:@"%@%d", imageName, i];
        UIImage * image = [CTMSGUtilities imageForNameInBundle:name];
        [array addObject:image];
    }
    _toImages = [array copy];
    [array removeAllObjects];
    imageName = @"ctmsg_chat_from_voice_msg_";
    for (int i = 1; i < 4; i++) {
        NSString * name = [NSString stringWithFormat:@"%@%d", imageName, i];
        UIImage * image = [CTMSGUtilities imageForNameInBundle:name];
        [array addObject:image];
    }
    _fromImages = [array copy];
}

#pragma mark - lazy

- (UIView *)voiceUnreadTagView {
    if (!_voiceUnreadTagView) {
        _voiceUnreadTagView = [UIView new];
        _voiceUnreadTagView.frame = CGRectMake(0, 0, 10, 10);
        _voiceUnreadTagView.layer.cornerRadius = 5;
        _voiceUnreadTagView.layer.masksToBounds = YES;
        _voiceUnreadTagView.backgroundColor = [UIColor redColor];
        [self.bubbleBackgroundView addSubview:_voiceUnreadTagView];
    }
    return _voiceUnreadTagView;
}

@end
