//
//  CTMSGEmojiBoardView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageLib/CTMSGEnumDefine.h>
#import "CTMSGEmoticonTabSource.h"

//@class CTMSGEmojiPageControl;
@protocol CTMSGEmojiViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGEmojiBoardView : UIView <UIScrollViewDelegate>

/*!
 表情背景的View
 */
@property(nonatomic, strong) UIScrollView *emojiBackgroundView;
@property(nonatomic, strong) UIView *emojiBottomView;
@property(nonatomic, strong) UIButton *emojiSendBtn;
@property(nonatomic, strong) UIPageControl *emojiPageControl;
@property(nonatomic, strong) UIButton *emojiDeleteBtn;

/*!
 当前的会话类型
 */
@property(nonatomic, assign) CTMSGConversationType conversationType;

/*!
 当前的会话ID
 */
@property(nonatomic, strong) NSString *targetId;


/*!
 表情输入的回调
 */
@property(nonatomic, weak) id<CTMSGEmojiViewDelegate> delegate;

/*!
 表情区域的大小
 */
@property(nonatomic, assign, readonly) CGSize contentViewSize;

/**
 *  init
 *
 *  @param frame            frame
 *  @param delegate         实现CTMSGEmojiViewDelegate的实体
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<CTMSGEmojiViewDelegate>)delegate;
/*!
 加载表情Label
 */
- (void)loadLabelView;

/*!
 发送按钮是否可点击
 @param sender 发送者
 */
- (void)enableSendButton:(BOOL)sender;
/**
 *  添加表情包（普通开发者调用添加表情包）
 *
 *  @param viewDataSource 每页表情的数据源代理，当滑动需要加载表情页时会回调代理的方法，您需要返回表情页的view
 */
- (void)addEmojiTab:(id<CTMSGEmoticonTabSource>)viewDataSource;
/**
 *  添加Extention表情包(用于第三方表情厂商添加表情包)
 *
 *  @param viewDataSource 每页表情的数据源代理，当滑动需要加载表情页时会回调代理的方法，您需要返回表情页的view
 */
- (void)addExtensionEmojiTab:(id<CTMSGEmoticonTabSource>)viewDataSource NS_UNAVAILABLE;
/**
 *  表情页页码以及选中的页
 */
- (void)setCurrentIndex:(int)index withTotalPages:(int)totalPageNum;

/**
 *  重新加载通过扩展方式加载的表情包，（调用这个方法会回调RCExtensionModule 协议实现的扩展通过 addEmojiTab
 * 加入的表情包不会重写加载）
 */
- (void)reloadExtensionEmoticonTabSource;

@end

/*!
 表情输入的回调
 */
@protocol CTMSGEmojiViewDelegate <NSObject>
@optional

/*!
 点击表情的回调
 
 @param emojiView 表情输入的View
 @param string    点击的表情对应的字符串编码
 */
- (void)didTouchEmojiView:(CTMSGEmojiBoardView *)emojiView touchedEmoji:(NSString *)string;

- (void)didRemoveEmojiView:(CTMSGEmojiBoardView *)emojiView;

/*!
 点击发送按钮的回调
 
 @param emojiView  表情输入的View
 @param sendButton 发送按钮
 */
- (void)didSendButtonEvent:(CTMSGEmojiBoardView *)emojiView sendButton:(UIButton *)sendButton;

@end


NS_ASSUME_NONNULL_END
