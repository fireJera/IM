//
//  CTMSGConversationCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CTMSGConversationCellDelegate;
@class CTMSGConversationModel;

@interface CTMSGConversationCell : CTMSGConversationBaseCell

/*!
 显示内容区的view
 */
@property(nonatomic, strong) UIView *detailContentView;

/*!
 会话Cell的点击监听器
 */
@property(nonatomic, weak) id<CTMSGConversationCellDelegate> delegate;

/*!
 Cell的头像背景View
 */
@property(nonatomic, strong) UIView *avatarBackgroundView;

/*!
 Cell头像View
 */
@property(nonatomic, strong) UIButton *avatarBtn;

/*!
 会话的标题
 */
@property(nonatomic, strong) UILabel *conversationTitle;

///*!
// 会话标题右侧的标签view
// */
//@property(nonatomic, strong) UIView *conversationTagView;

/*!
 显示最后一条内容的Label
 */
@property(nonatomic, strong) UILabel *messageContentLabel;

/*!
 显示最后一条消息发送时间的Label
 */
@property(nonatomic, strong) UILabel *messageCreatedTimeLabel;

/*!
 头像右上角未读消息提示的View
 */
@property(nonatomic, strong) UILabel *unreadCountLabel;
@property(nonatomic, strong) CALayer *unreadBGLayer;
@property(nonatomic, strong) UIImageView *topTagImageView;

///*!
// 会话免打扰状态显示的View
// */
//@property(nonatomic, strong) UIImageView *conversationStatusImageView;

///*!
// Cell中显示的头像形状
//
// @discussion 默认值为当前MessageKit的全局设置值（RCIM中的globalConversationAvatarStyle）。
// */
//@property(nonatomic, assign) RCUserAvatarStyle portraitStyle;

///*!
// 是否进行新消息提醒
//
// @discussion 此属性默认会根据会话设置的提醒状态进行设置。
// */
//@property(nonatomic, assign) BOOL enableNotification;

///*!
// 会话中有未读消息时，是否在头像右上角的bubbleTipView中显示数字
//
// @discussion 默认值为YES。
// 您可以在RCConversationListViewController的willDisplayConversationTableCell:atIndexPath:回调中进行设置。
// */
//@property(nonatomic, assign) BOOL isShowNotificationNumber;

///*!
// 是否在群组和讨论组会话Cell中隐藏发送者的名称
// */
//@property(nonatomic, assign) BOOL hideSenderName;
/*!
 是否显示toptag 默认 no
 */
@property(nonatomic, assign) BOOL showTopTag;

/*!
 非置顶的Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *cellBackgroundColor;

/*!
 置顶Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *topCellBackgroundColor;

///*!
// 显示最后一台消息发送状态
// */
//@property(nonatomic, strong) UIImageView *lastSendMessageStatusView;

///*!
// 显示会话状态的view
// */
//@property(nonatomic, strong) RCConversationStatusView *statusView;

@end

/*!
 会话Cell的点击监听器
 */
@protocol CTMSGConversationCellDelegate <NSObject>

/*!
 点击Cell头像的回调
 
 @param model 会话Cell的数据模型
 */
- (void)didTapCellAvatar:(CTMSGConversationModel *)model;

/*!
 长按Cell头像的回调
 
 @param model 会话Cell的数据模型
 */
- (void)didLongPressCellAvatar:(CTMSGConversationModel *)model NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
