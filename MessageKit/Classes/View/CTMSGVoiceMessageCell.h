//
//  CTMSGVoiceMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"

extern const int CTMSGVoiceMessageImageRight;
extern const int CTMSGVoiceMessageTextRight;

NS_ASSUME_NONNULL_BEGIN

/*!
 开始语音播放的Notification
 */
UIKIT_EXTERN NSString *const kNotificationPlayVoice;
/*!
 语音消息播放停止的Notification
 */
UIKIT_EXTERN NSString *const kNotificationStopVoicePlayer;


@interface CTMSGVoiceMessageCell : CTMSGMessageCell

/*!
 语音播放的View
 */
@property(nonatomic, strong) UIImageView *playVoiceView;

/*!
 显示是否已播放的View
 */
@property(nonatomic, strong) UIView *voiceUnreadTagView;

/*!
 显示语音时长的Label
 */
@property(nonatomic, strong) UILabel *voiceDurationLabel;

/*!
 播放语音
 */
- (void)playVoice;
- (void)stopPlayVoice;

@end

NS_ASSUME_NONNULL_END
