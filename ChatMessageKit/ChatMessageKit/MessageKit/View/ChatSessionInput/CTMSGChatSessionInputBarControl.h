//
//  CTMSGChatSessionInputBarControl.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMSGEnumDefine.h"
#import <CoreLocation/CoreLocation.h>

@class CTMSGPluginBoardView, CTMSGEmojiBoardView, CTMSGUserInfo;
@class CTMSGChatVoiceInputView, CTMSGChatAlbumPickView;

extern const CGFloat CTMSGInputNormalHeight;
//extern const CGFloat CTMSGInputEmojiHeight;
extern const CGFloat CTMSGInputEditingHeight;

///输入栏扩展输入的唯一标示
static const int CTMSG_InputBarVoice = 1000;
static const int CTMSG_InputBarAlbum = 1001;
static const int CTMSG_InputBarCamera = 1002;
static const int CTMSG_InputBarEmoji = 1003;
static const int CTMSG_InputBarPlugin = 1004;

static const int CTMSG_InputBarPluginVoiceCall = 2000;
static const int CTMSG_InputBarPluginVideoCall = 2001;
static const int CTMSG_InputBarPluginLocationCall = 2002;
static const int CTMSG_InputBarPluginShareLocationCall = 2003;
static const int CTMSG_InputBarPluginGift = 2004;
static const int CTMSG_InputBarPluginVoceCall = 2005;

///*!
// 输入工具栏的显示布局
// */
//typedef NS_ENUM(NSInteger, CTMSGChatSessionInputBarControlStyle) {
//    /*!
//     切换-输入框-扩展
//     */
//    RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION = 0,
//    /*!
//     扩展-输入框-切换
//     */
//    RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER_SWITCH = 1,
//    /*!
//     输入框-切换-扩展
//     */
//    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH_EXTENTION = 2,
//    /*!
//     输入框-扩展-切换
//     */
//    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION_SWITCH = 3,
//    /*!
//     切换-输入框
//     */
//    RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER = 4,
//    /*!
//     输入框-切换
//     */
//    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH = 5,
//    /*!
//     扩展-输入框
//     */
//    RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER = 6,
//    /*!
//     输入框-扩展
//     */
//    RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION = 7,
//    /*!
//     输入框
//     */
//    RC_CHAT_INPUT_BAR_STYLE_CONTAINER = 8,
//};

/*!
 输入工具栏的菜单类型
 */
typedef NS_ENUM(NSInteger, CTMSGChatSessionInputBarControlType) {
    /*!
     默认类型，非公众服务
     */
    CTMSGChatSessionInputBarControlDefaultType = 0,
//    /*!
//     公众服务
//     */
//    CTMSGChatSessionInputBarControlPubType = 1,
//    
//    /*!
//     客服机器人
//     */
//    CTMSGChatSessionInputBarControlCSRobotType = 2,
//
//    /*!
//     客服机器人
//     */
//    CTMSGChatSessionInputBarControlNoAvailableType = 3
};

/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, CTMSGChatSessionInputBarInputType) {
    /*!
     文本输入模式
     */
    CTMSGChatSessionInputBarInputTypeText = 0,
    /*!
     语音输入模式
     */
    CTMSGChatSessionInputBarInputTypeVoice = 1,
    /*!
     语音输入模式
     */
    CTMSGChatSessionInputBarInputTypeAlbum = 2,
    /*!
     语音输入模式
     */
    CTMSGChatSessionInputBarInputTypeCamera = 3,
    /*!
     语音输入模式
     */
    CTMSGChatSessionInputBarInputTypeEmoji = 4,
    /*!
     扩展输入模式
     */
    CTMSGChatSessionInputBarInputTypeExtention = 5
};

/*!
 输入工具栏的输入模式
 */
typedef NS_ENUM(NSInteger, KBottomBarStatus) {
    /*!
     初始状态
     */
    KBottomBarDefaultStatus = 0,
    /*!
     文本输入状态
     */
    KBottomBarKeyboardStatus,
    /*!
     功能板输入模式
     */
    KBottomBarPluginStatus,
    /*!
     表情输入模式
     */
    KBottomBarEmojiStatus,
    /*!
     语音消息输入模式
     */
    KBottomBarVoiceStatus,
    /*!
     选择相册输入模式
     */
    KBottomBarAlbumStatus,
    /*!
     摄像头输入模式
     */
    KBottomBarCameraStatus,
    /*!
     锁
     */
    KBottomBarLockStatus,
};

/*!
 输入工具栏的点击监听器
 */
@protocol CTMSGChatSessionInputBarControlDelegate;

///*!
// 输入工具栏的数据源
// */
//@protocol CTMSGChatSessionInputBarControlDataSource;


NS_ASSUME_NONNULL_BEGIN

@interface CTMSGChatSessionInputBarControl : UIView

/*!
 所处的会话页面View
 */
@property(nonatomic, assign, readonly) UIView *containerView;


#pragma mark - normal view
/*!
 容器View  正常情况先看见的
 */
@property(nonatomic, strong) UIView *inputContainerView;

/*!
 文本输入框
 */
@property(nonatomic, strong) UITextView *inputTextView;

/*!
 语音与文本输入切换的按钮
 */
@property(nonatomic, strong) UIButton *voiceButton;

/*!
 语音与文本输入切换的按钮
 */
@property(nonatomic, strong) UIButton *albumButton;

/*!
 相机的按钮
 */
@property(nonatomic, strong) UIButton *cameraButton;

/*!
 表情的按钮
 */
@property(nonatomic, strong) UIButton *emojiButton;

/*!
 扩展输入的按钮
 */
@property(nonatomic, strong) UIButton *additionalButton NS_UNAVAILABLE;

/*!
 所处的会话页面View
 */
@property(nonatomic, strong) UIVisualEffectView *lockView;

/*!
 所处的会话页面View
 */
@property(nonatomic, strong) UILabel *lockLabel;

#pragma mark - bottom view

@property(nonatomic, strong) UIView *bottomContainerView;
@property(nonatomic, strong) CTMSGChatVoiceInputView *voiceRecordView;
@property(nonatomic, strong) CTMSGChatAlbumPickView *albumPickView;

/*!
 表情View
 */
@property(nonatomic, strong) CTMSGEmojiBoardView *emojiBoardView;

/*!
 输入扩展功能板View
 */
@property(nonatomic, strong) CTMSGPluginBoardView *pluginBoardView NS_UNAVAILABLE;

#pragma mark - date

@property (nonatomic, assign, readonly) CGFloat height;

/*!
 当前的会话类型
 */
@property(nonatomic, assign) CTMSGConversationType conversationType;

/*!
 当前的会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<CTMSGChatSessionInputBarControlDelegate> delegate;
//
///*!
// 输入工具栏获取用户信息的回调
// */
//@property(weak, nonatomic) id<CTMSGChatSessionInputBarControlDataSource> dataSource NS_UNAVAILABLE;

/*!
 公众服务菜单切换的按钮
 */
@property(nonatomic, strong) UIButton *pubSwitchButton NS_UNAVAILABLE;

/*!
 客服机器人转人工切换的按钮
 */
@property(nonatomic, strong) UIButton *robotSwitchButton NS_UNAVAILABLE;

/*!
 当前的输入状态
 */
@property(nonatomic) KBottomBarStatus currentBottomBarStatus;

/*!
 设置输入工具栏的样式 readwrite 表示可设置
 @discussion 您可以在会话页面RCConversationViewController的viewDidLoad之后设置，改变输入工具栏的样式。
 */
@property (nonatomic, assign, readwrite) CTMSGChatSessionInputBarControlType inputBarType;
/*!
 设置默认的输入框类型
 */
@property (nonatomic, assign, readwrite) CTMSGChatSessionInputBarInputType defaultInputType;

//
///*!
// 公众服务账号菜单
// */
//@property(nonatomic, strong) RCPublicServiceMenu *publicServiceMenu;

/*!
 草稿
 */
@property(nonatomic, strong) NSString *draft;

/*!
 草稿
 */
@property(nonatomic, assign) CGFloat keyboardHeight;

///*!
// @提醒信息
// */
//@property(nonatomic, strong, readonly) RCMentionedInfo *mentionedInfo;

/*!
 是否允许@功能
 */
@property(nonatomic, assign) BOOL isMentionedEnabled NS_UNAVAILABLE;

/*!
 初始化输入工具栏
 
 @param frame            显示的Frame
 @param containerView    所处的会话页面View
 @param controlType      菜单类型
 @param defaultInputType 默认的输入模式
 
 @return 输入工具栏对象
 */
- (instancetype)initWithFrame:(CGRect)frame
            withContainerView:(UIView *)containerView
                  controlType:(CTMSGChatSessionInputBarControlType)controlType
             defaultInputType:(CTMSGChatSessionInputBarInputType)defaultInputType;

//- (instancetype)initWithFrame:(CGRect)frame
//            withContainerView:(UIView *)containerView
//                  controlType:(CTMSGChatSessionInputBarControlType)controlType
//                 controlStyle:(CTMSGChatSessionInputBarControlStyle)controlStyle
//             defaultInputType:(CTMSGChatSessionInputBarInputType)defaultInputType;


/*!
 销毁公众账号弹出的菜单
 */
- (void)dismissPublicServiceMenuPopupView NS_UNAVAILABLE;

/*!
 撤销录音
 */
- (void)cancelVoiceRecord;

/*!
 结束录音
 */
- (void)endVoiceRecord;

/*!
 View即将显示的回调
 */
- (void)containerViewWillAppear;

/*!
 View已经显示的回调
 */
- (void)containerViewDidAppear;

/*!
 View即将隐藏的回调
 */
- (void)containerViewWillDisappear;
/*!
 设置输入框的输入状态
 
 @param status          输入框状态
 @param animated        是否使用动画效果
 
 @discussion 如果需要设置，请在输入框执行containerViewWillAppear之后（即会话页面viewWillAppear之后）。
 */
- (void)updateStatus:(KBottomBarStatus)status animated:(BOOL)animated;

/*!
 重置到默认状态
 */
- (void)resetToDefaultStatus;

/*!
 内容区域大小发生变化。
 
 @discussion 当本view所在的view frame发生变化，需要重新计算本view的frame时，调用此方法
 */
- (void)containerViewSizeChanged;

/*!
 添加被@的用户
 
 @param userInfo    被@的用户信息
 */
- (void)addMentionedUser:(CTMSGUserInfo *)userInfo NS_UNAVAILABLE;

/*!
 打开系统相册，选择图片
 
 @discussion 选择结果通过delegate返回
 */
- (void)openAlbumController;

/*!
 打开系统相机，拍摄图片
 
 @discussion 拍摄结果通过delegate返回
 */
- (void)openCameraController;

/*!
 打开地图picker，选择位置
 
 @discussion 选择结果通过delegate返回
 */
- (void)openLocationPicker NS_UNAVAILABLE;

/*!
 打开文件选择器，选择文件
 
 @discussion 选择结果通过delegate返回
 */
- (void)openFileSelector NS_UNAVAILABLE;

- (void)openDynamicFunction:(NSInteger)functionTag NS_UNAVAILABLE;

@end

/*!
 输入工具栏的点击监听器
 */
@protocol CTMSGChatSessionInputBarControlDelegate <NSObject>

/*!
 显示ViewController
 
 @param viewController 需要显示的ViewController
 @param functionTag    功能标识
 */
- (void)presentViewController:(UIViewController *)viewController functionTag:(NSInteger)functionTag;

@optional

/*!
 输入工具栏尺寸（高度）发生变化的回调
 
 @param chatInputBar 输入工具栏
 @param frame        输入工具栏最终需要显示的Frame
 */
- (void)chatInputBar:(CTMSGChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame;

/*!
 点击键盘Return按钮的回调
 
 @param inputTextView 文本输入框
 */
- (void)inputTextViewDidTouchSendKey:(UITextView *)inputTextView;

/*!
 点击客服机器人切换按钮的回调
 */
- (void)robotSwitchButtonDidTouch NS_UNAVAILABLE;

/*!
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

///*!
// 公众服务菜单的点击回调
//
// @param selectedMenuItem 点击的公众服务菜单项
// */
//- (void)onPublicServiceMenuItemSelected:(RCPublicServiceMenuItem *)selectedMenuItem NS_UNAVAILABLE;

/*!
 点击扩展功能板中的扩展项的回调
 
 @param pluginBoardView 当前扩展功能板
 @param tag             点击的扩展项的唯一标示符
 */
- (void)pluginBoardView:(CTMSGPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag;

/*!
 点击表情的回调
 
 @param emojiView    表情输入的View
 @param touchedEmoji 点击的表情对应的字符串编码
 */
- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchedEmoji:(NSString *)touchedEmoji;

/*!
 点击发送按钮的回调
 
 @param emojiView  表情输入的View
 @param sendButton 发送按钮
 */
- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchSendButton:(UIButton *)sendButton;
- (void)emojiViewRemoveEmoji:(CTMSGEmojiBoardView *)emojiView;

/*!
 开始录制语音消息
 */
- (void)recordDidBegin;

/*!
 取消录制语音消息
 */
- (void)recordDidCancel;

/*!
 结束录制语音消息
 */
- (void)recordDidEnd:(NSData *)recordData recordPath:(NSString *)path duration:(long)duration error:(nullable NSError *)error;

/*!
 选完照片后
 */
- (void)pickImages:(NSArray<UIImage *> *)images;

/*!
 相机拍照图片
 
 @param image   相机拍摄，选择发送的图片
 */
- (void)imageDidCapture:(UIImage *)image;

/**
 相机录制小视频
 
 @param url 小视频url
 */
- (void)sightDidFinishRecord:(NSString *)url thumbnail:(UIImage *)image duration:(NSUInteger)duration;

/*!
 地理位置选择完成之后的回调
 @param location       位置的二维坐标
 @param locationName   位置的名称
 @param mapScreenShot  位置在地图中的缩略图
 */
- (void)locationDidSelect:(CLLocationCoordinate2D)location
             locationName:(NSString *)locationName
            mapScreenShot:(UIImage *)mapScreenShot NS_UNAVAILABLE;

/*!
 选择文件列表
 
 @param filePathList   被选中的文件路径list
 */
- (void)fileDidSelect:(NSArray *)filePathList NS_UNAVAILABLE;

/*!
 输入工具栏状态变化时的回调（暂未实现）
 
 @param bottomBarStatus 当前状态
 */
- (void)chatSessionInputBarStatusChanged:(KBottomBarStatus)bottomBarStatus;
@end
//
//@protocol CTMSGChatSessionInputBarControlDataSource <NSObject>
//
///*!
// 获取待选择的用户ID列表
//
// @param completion  获取完成的回调
// @param functionTag 功能标识
// */
//- (void)getSelectingUserIdList:(void (^)(NSArray<NSString *> *userIdList))completion functionTag:(NSInteger)functionTag;
//
///*!
// 获取待选择的UserId的用户信息
//
// @param userId           用户ID
// @return 用户信息
// */
//- (CTMSGUserInfo *)getSelectingUserInfo:(NSString *)userId;
//
//@end

NS_ASSUME_NONNULL_END
