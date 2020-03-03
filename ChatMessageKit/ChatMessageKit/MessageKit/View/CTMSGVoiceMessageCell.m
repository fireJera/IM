//
//  CTMSGVoiceMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGVoiceMessageCell.h"
#import "CTMSGMessageModel.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGContentView.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"
#import "CTMSGUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import "CTMSGAudioRecordTool.h"
#import "CTMSGAMRDataConverter.h"

NSString *const kNotificationPlayVoice = @"kNotificationPlayVoice";
NSString *const kNotificationStopVoicePlayer = @"kNotificationStopVoicePlayer";

const int CTMSGVoiceMessageImageRight = 12;
const int CTMSGVoiceMessageTextRight = 4;

@interface CTMSGVoiceMessageCell () <AVAudioPlayerDelegate>

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
    [self p_ctmsg_updateCell];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
        CTMSGVoiceMessage * message = (CTMSGVoiceMessage *)self.model.content;
        _voiceDurationLabel.text = [NSString stringWithFormat:@"%ld", message.duration];
        if (self.model.receivedStatus != ReceivedStatus_LISTENED) {
            [self.bubbleBackgroundView addSubview:self.voiceUnreadTagView];
        }
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
    //拉伸图片
    if (self.messageDirection == CTMSGMessageDirectionReceive) {
        _voiceDurationLabel.textColor = [UIColor whiteColor];
        messageContentViewRect.size = bubbleBackgroundViewSize;
        bubbleImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_to"];
        voiceImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_to_voice_msg_1"];
    } else {
        _voiceDurationLabel.textColor = [UIColor ctmsg_color212121];
        messageContentViewRect.size = bubbleBackgroundViewSize;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading);
        bubbleImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_from"];
        voiceImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_from_voice_msg_1"];
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
    self.bubbleBackgroundView.image = [bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(bubbleImage.size.height * 0.3, bubbleImage.size.width * 0.3,
                                                                                          bubbleImage.size.height * 0.7, bubbleImage.size.width * 0.7)];
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
//#pragma mark - notification
//
//- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
//
//}

#pragma mark - public

- (void)playVoice {
    if (_audioPlayer.playing) {
        [_audioPlayer stop];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayVoice object:nil];
    CTMSGVoiceMessage * message = (CTMSGVoiceMessage *)self.model.content;
    NSData * data = message.wavAudioData;
    NSString * wavPath = [CTMSGAudioRecordTool shareRecorder].playWAVPath;
    NSString * amrPath = [CTMSGAudioRecordTool shareRecorder].playAMRPath;
    [data writeToFile:amrPath atomically:YES];
    [[CTMSGAMRDataConverter sharedAMRDataConverter] convertAmrToWav:amrPath wavSavePath:wavPath];
    NSError * error;
    NSURL * url = [NSURL fileURLWithPath:wavPath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops=0;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStopVoicePlayer object:self.model];
    }
}

#pragma mark - private

+ (CGSize)getBubbleSize:(float)duration {
    CGSize bubbleSize = CGSizeMake(CTMSGMessageCellBubbleMinWidth + duration * 0.8, CTMSGMessageCellBubbleMinHeight);
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
    _playVoiceView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
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
}

#pragma mark - lazy

- (UIImageView *)voiceUnreadTagView {
    if (!_voiceUnreadTagView) {
        _voiceUnreadTagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    }
    return _voiceUnreadTagView;
}

@end
