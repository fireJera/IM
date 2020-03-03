//
//  CTMSGMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageBaseCell.h"
#import "CTMSGBubbleImageView.h"

//气泡到头像的水平距离
extern const int HeadAndContentSpacing;
extern const int CTMSGMessageCellAvatarWith;
//头像距离左边的距离
extern const int CTMSGMessageCellAvatarLeading;

extern const int CTMSGMessageCellBubbleLeading;
extern const int CTMSGMessageCellBubbleMinWidth;
extern const int CTMSGMessageCellBubbleMinHeight;

@class CTMSGContentView;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGMessageCell : CTMSGMessageBaseCell

/*!
 消息发送者的用户头像
 */
@property(nonatomic, strong) UIButton *portraitBtn;

/*!
 消息内容的View
 */
@property(nonatomic, strong) CTMSGContentView *messageContentView;

/*!
 消息的气泡
 */
@property(nonatomic, strong) CTMSGBubbleImageView *bubbleBackgroundView;

/*!
 显示发送状态的View
 
 @discussion 其中包含messageFailedStatusView子View。
 */
@property(nonatomic, strong) UIView *statusContentView;

/*!
 显示发送失败状态的View
 */
@property(nonatomic, strong) UIButton *messageFailedStatusView;

///*!
// 消息内容的View的宽度
// */
//@property(nonatomic, strong) UIImageView * lockImageView;

///*!
// 消息内容的View的宽度
// */
//@property(nonatomic, strong) UILabel * lockLable;

/*!
 消息发送指示View
 */
@property(nonatomic, strong) UIActivityIndicatorView *messageActivityIndicatorView;

/*!
 消息内容的View的宽度
 */
@property(nonatomic, readonly) CGFloat messageContentViewWidth;

/*!
 更新消息发送状态
 
 @param model 消息Cell的数据模型
 */
- (void)updateStatusContentView:(CTMSGMessageModel *)model NS_REQUIRES_SUPER;

#pragma mark - NS_UNAVAILABLE
///*!
// 消息发送者的用户名称
// */
//@property(nonatomic, strong) UILabel *nicknameLabel NS_UNAVAILABLE;

///*!
// 是否显示用户名称
// */
//@property(nonatomic, readonly) BOOL isDisplayNickname NS_UNAVAILABLE;

/*!
 显示消息已阅读状态的View
 */
@property(nonatomic, strong) UIView *messageHasReadStatusView NS_UNAVAILABLE;

/*!
 显示消息发送成功状态的View
 */
@property(nonatomic, strong) UIView *messageSendSuccessStatusView NS_UNAVAILABLE;

#pragma mark - NS_UNAVAILABLE totaly

/*!
 显示是否消息回执的Button
 
 @discussion 仅在群组和讨论组中显示
 */
@property(nonatomic, strong) UIButton *receiptView NS_UNAVAILABLE;

/*!
 消息阅读人数的Label
 
 @discussion 仅在群组和讨论组中显示
 */
@property(nonatomic, strong) UILabel *receiptCountLabel NS_UNAVAILABLE;


/*!
 设置当前消息Cell的数据模型
 
 @param model 消息Cell的数据模型
 */
- (void)setDataModel:(CTMSGMessageModel *)model NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
