//
//  CTMSGConversationViewController.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageLib/CTMSGEnumDefine.h>
#import "CTMSGChatSessionInputBarControl.h"
#import <MessageLib/CTMSGImageMessage.h>
#import <MessageLib/CTMSGUploadMediaStatusListener.h>
#import <MessageLib/CTMSGLocationMessage.h>
//#import "MessageLib/CTMSGImageMessage.h"
//#import "CTMSGChatCameraViewController.h"

@class CTMSGPluginBoardView, CTMSGMessageModel, CTMSGMessageContent, CTMSGMessageBaseCell;
//@classs CTMSGMessage, CTMSGUploadMediaStatusListener, CTMSGMessageBaseCell, CTMSGLocationMessage;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGConversationViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate, UIScrollViewDelegate>

#pragma mark - 初始化

/*!
 初始化会话页面
 
 @param conversationType 会话类型
 @param targetId         目标会话ID
 
 @return 会话页面对象
 */
- (id)initWithConversationType:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;
#pragma mark - view
/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/*!
 会话页面的CollectionView Layout
 */
@property(nonatomic, strong) UICollectionViewFlowLayout *customFlowLayout;

/*!
 会话页面下方的输入工具栏
 */
@property(nonatomic, strong) CTMSGChatSessionInputBarControl *chatSessionInputBarControl;

/*!
 会话扩展显示区域
 
 @discussion 可以自定义显示会话页面的view。
 */
@property(nonatomic, strong) UIView *extensionView;

#pragma mark - 会话属性

/*!
 当前会话的会话类型
 */
@property(nonatomic) CTMSGConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

#pragma mark - 会话页面属性

@property (nonatomic, strong, readonly, class) NSHashTable<CTMSGConversationViewController *> * allInstance;
/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即CTMSGMessageModel对象。
 @warning 非线程安全，请在主线程操作该属性
 */
@property(nonatomic, strong) NSMutableArray<CTMSGMessageModel *> *conversationDataRepository;

///*!
// 输入框的默认输入模式
//
// @discussion 默认值为RCChatSessionInputBarInputText，即文本输入模式。 请在[super viewWillAppear:animated]之后调用
// */
//@property(nonatomic) CTMSGChatSessionInputBarInputType defaultInputType;

/*!
 发送新拍照的图片完成之后，是否将图片在本地另行存储。
 
 @discussion 如果设置为YES，您需要在saveNewPhotoToLocalSystemAfterSendingSuccess:回调中自行保存。
 */
@property(nonatomic, assign) BOOL enableSaveNewPhotoToLocalSystem;

/*!
 该会话的未读消息数
 */
@property(nonatomic, assign) NSInteger unReadMessage;

/*!
 目标会话ID
 */
@property(nonatomic, assign) BOOL customUpload;


#pragma mark - NS_UNAVAILABLE property
/**
 进入页面时定位的消息的发送时间
 
 @discussion 用于消息搜索之后点击进入页面等场景
 */
@property(nonatomic, assign) long long locatedMessageSentTime NS_UNAVAILABLE;

#pragma mark 导航栏返回按钮中的未读消息数提示
/*!
 需要统计未读数的会话类型数组（在导航栏的返回按钮中显示）
 
 @discussion 此属性表明在导航栏的返回按钮中需要统计显示哪部分的会话类型的未读数。
 (需要将CTMSGConversationType转为NSNumber构建Array)
 */
@property(nonatomic, strong) NSArray<NSNumber *> *displayConversationTypeArray NS_UNAVAILABLE;


#pragma mark 右上角的未读消息数提示
/*!
 当收到的消息超过一个屏幕时，进入会话之后，是否在右上角提示上方存在的未读消息数
 
 @discussion 默认值为NO。
 开启该提示功能之后，当一个会话收到大量消息时（超过一个屏幕能显示的内容），
 进入该会话后，会在右上角提示用户上方存在的未读消息数，用户点击该提醒按钮，会跳转到最开始的未读消息。
 */
@property(nonatomic, assign) BOOL enableUnreadMessageIcon NS_UNAVAILABLE;

/*!
 右上角未读消息数提示的Label
 
 @discussion 当 150 >= unReadMessage > 10  右上角会显示未读消息数。
 */
@property(nonatomic, strong) UILabel *unReadMessageLabel NS_UNAVAILABLE;

/*!
 右上角未读消息数提示的按钮
 */
@property(nonatomic, strong) UIButton *unReadButton NS_UNAVAILABLE;

#pragma mark 右下角的未读消息数提示
/*!
 当前阅读区域的下方收到消息时，是否在会话页面的右下角提示下方存在未读消息
 
 @discussion 默认值为NO。
 开启该提示功能之后，当会话页面滑动到最下方时，此会话中收到消息会自动更新；
 当用户停留在上方某个区域阅读时，此会话收到消息时，会在右下角显示未读消息提示，而不会自动滚动到最下方，
 用户点击该提醒按钮，会滚动到最下方。
 */
@property(nonatomic, assign) BOOL enableNewComingMessageIcon NS_UNAVAILABLE;

/*!
 右下角未读消息数提示的Label
 */
@property(nonatomic, strong) UILabel *unReadNewMessageLabel NS_UNAVAILABLE;

#pragma mark - 显示设置

/*!
 收到的消息是否显示发送者的名字
 
 @discussion 默认值为YES。
 您可以针对群聊、聊天室、单聊等不同场景，自己定制是否显示发送方的名字。
 */
@property(nonatomic) BOOL displayUserNameInCell NS_UNAVAILABLE;

/*!
 设置进入聊天室需要获取的历史消息数量（仅在当前会话为聊天室时生效）
 
 @discussion 此属性需要在viewDidLoad之前进行设置。
 -1表示不获取任何历史消息，0表示不特殊设置而使用SDK默认的设置（默认为获取10条），0<messageCount<=50为具体获取的消息数量,最大值为50。注：如果是7.x系统获取历史消息数量不要大于30
 */
@property(nonatomic, assign) int defaultHistoryMessageCountOfChatRoom NS_UNAVAILABLE;


#pragma mark - 界面操作 method
- (void)ctmsg_resetFrame:(CGRect)barFrame;
//- (void)willLoadNextPageMessage;
- (BOOL)didShowAllAfterLoadNextPageMessage;

// 获取消息 第一次获取消息 和之后的加载更多都是通过此方法
- (void)ctmsg_fetchMessages;

- (void)ctmsg_fetchDBMessage;
- (void)ctmsg_fetchNetMessage:(void(^)(NSArray<CTMSGMessage *> * _Nullable serverMessages))resultBlock;

//- (void)ctmsg_insertNewDBMessage:(NSArray<CTMSGMessage *> *)messages;
//- (void)refreshViewAfterFetchMessages:(NSInteger)topIndex;

#pragma mark - 输入工具栏

/*!
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/*!
 扩展功能板的点击回调
 
 @param pluginBoardView 输入扩展功能板View
 @param tag             输入扩展功能(Item)的唯一标示
 */
- (void)pluginBoardView:(CTMSGPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag;

/*!
 滚动到列表最下方
 
 @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

#pragma mark 发送消息
/*!
 发送消息
 
 @param messageContent 消息的内容
 @param pushContent    接收方离线时需要显示的远程推送内容
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent来定义推送内容，否则将不会进行远程推送。
 
 如果您需要设置发送的pushData，可以使用RCIM的发送消息接口。
 */
- (void)sendMessage:(CTMSGMessageContent *)messageContent pushContent:(nullable NSString *)pushContent;

/*!
 发送媒体消息(上传图片或文件到App指定的服务器)
 
 @param messageContent 消息的内容
 @param pushContent    接收方离线时需要显示的远程推送内容
 @param appUpload      是否上传到App指定的服务器
 
 @discussion
 此方法用于上传媒体信息到您自己的服务器，此时需要将appUpload设置为YES，并实现uploadMedia:uploadListener:回调。
 需要您在该回调中上传媒体信息（图片或文件），并通过uploadListener监听通知SDK同步显示上传进度。
 
 如果appUpload设置为NO，将会和普通媒体消息的发送一致，上传到默认的服务器并发送。
 */
- (void)sendMediaMessage:(CTMSGMessageContent *)messageContent
             pushContent:(nullable NSString *)pushContent
               appUpload:(BOOL)appUpload;

/*!
 上传媒体信息到App指定的服务器的回调
 
 @param message        媒体消息（图片消息或文件消息）的实体
 @param uploadListener SDK图片上传进度监听
 
 @discussion 如果您通过sendMediaMessage:pushContent:appUpload:接口发送媒体消息，则必须实现此回调。
 您需要在此回调中通过uploadListener将上传媒体信息的进度和结果通知SDK，SDK会根据这些信息，自动更新UI。
 */
- (void)uploadMedia:(CTMSGMessage *)message uploadListener:(CTMSGUploadMediaStatusListener *)uploadListener;

/*!
 取消上传媒体消息。
 
 @param model        媒体消息（文件消息）的Model
 
 @discussion 如果您通过sendMediaMessage:pushContent:appUpload:发送媒体消息（上传媒体内容到App服务器），需要
 重写此函数，在此函数中取消掉您的上传，并调用uploadListener的cancelBlock告诉SDK该发送已经取消。目前仅支持文件消息的取消
 */
- (void)cancelUploadMedia:(CTMSGMessageModel *)model;
/*!
 重新发送消息
 
 @param model 消息的内容
 
 @discussion 发送消息失败，点击小红点时，会将本地存储的原消息实体删除，回调此接口将消息内容重新发送。
 如果您需要重写此接口，请注意调用super。
 */
- (void)resendMessage:(CTMSGMessageModel *)model;

#pragma mark 插入消息
/*!
 在会话页面中插入一条消息并展示
 
 @param message 消息实体
 
 @discussion 通过此方法插入一条消息，会将消息实体对应的内容Model插入数据源中，并更新UI。
 请注意，这条消息只会在 UI 上插入，并不会存入数据库。
 用户调用这个接口插入消息之后，如果退出会话页面再次进入的时候，这条消息将不再显示。
 */
- (void)appendAndDisplayMessage:(CTMSGMessage *)message;

#pragma mark 删除消息
/*!
 删除消息并更新UI
 
 @param model 消息Cell的数据模型
 */
- (void)deleteMessage:(CTMSGMessageModel *)model;

#pragma mark 撤回消息
/*!
 撤回消息并更新UI
 
 @param messageId 被撤回的消息Id
 @discussion 只有存储并发送成功的消息才可以撤回。
 */
- (void)recallMessage:(long)messageId;

#pragma mark - 消息操作的回调

/*!
 准备发送消息的回调
 
 @param messageContent 消息内容
 
 @return 修改后的消息内容
 
 @discussion 此回调在消息准备向外发送时会回调，您可以在此回调中对消息内容进行过滤和修改等操作。
 如果此回调的返回值不为nil，SDK会对外发送返回的消息内容。
 */
- (CTMSGMessageContent *)willSendMessage:(CTMSGMessageContent *)messageContent;

- (void)prepareWorkForSendImagesMessagesTask:(void(^ _Nullable )(BOOL shouldSend))task;
- (void)finishWorkForSendImagesMessages;

- (NSString *)customCellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CTMSGMessageModel *)customMessageoModelForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)customCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath;
+ (BOOL)conversationOpenedWithTargetId:(NSString *)targetId;

/*!
 发送消息完成的回调
 
 @param status          发送状态，0表示成功，非0表示失败
 @param messageContent   消息内容
 */
- (void)didSendMessage:(NSInteger)status content:(CTMSGMessageContent *)messageContent;

/*!
 取消了消息发送的回调
 
 @param messageContent   消息内容
 */
- (void)didCancelMessage:(CTMSGMessageContent *)messageContent;

/*!
 即将在会话页面插入消息的回调
 
 @param message 消息实体
 @return        修改后的消息实体
 
 @discussion 此回调在消息准备插入数据源的时候会回调，您可以在此回调中对消息进行过滤和修改操作。
 如果此回调的返回值不为nil，SDK会将返回消息实体对应的消息Cell数据模型插入数据源，并在会话页面中显示。
 */
- (CTMSGMessage *)willAppendAndDisplayMessage:(CTMSGMessage *)message;

/*!
 即将显示消息Cell的回调
 
 @param cell        消息Cell
 @param indexPath   该Cell对应的消息Cell数据模型在数据源中的索引值
 
 @discussion 您可以在此回调中修改Cell的显示和某些属性。
 */
- (void)willDisplayMessageCell:(CTMSGMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - 自定义消息
/*!
 注册自定义消息的Cell
 
 @param cellClass     自定义消息cell的类
 @param messageClass  自定义消息Cell对应的自定义消息的类，该自定义消息需要继承于CTMSGMessageContent
 
 @discussion
 你需要在cell中重写CTMSGMessageBaseCell基类的sizeForMessageModel:withCollectionViewWidth:referenceExtraHeight:来计算cell的高度。
 */
- (void)registerClass:(Class)cellClass forMessageClass:(Class)messageClass;

/*!
 自定义消息Cell显示的回调
 
 @param collectionView  当前CollectionView
 @param indexPath       该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                自定义消息需要显示的Cell
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在会话页面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (CTMSGMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 自定义消息Cell显示的回调
 
 @param collectionView          当前CollectionView
 @param collectionViewLayout    当前CollectionView Layout
 @param indexPath               该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                        自定义消息Cell需要显示的高度
 
 @discussion 自定义消息如果需要显示，则必须先通过RCIM的registerMessageType:注册该自定义消息类型，
 并在会话页面中通过registerClass:forCellWithReuseIdentifier:注册该自定义消息的Cell，否则将此回调将不会被调用。
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 未注册消息Cell显示的回调
 
 @param collectionView  当前CollectionView
 @param indexPath       该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                未注册消息需要显示的Cell
 
 @discussion
 未注册消息的显示主要用于App未雨绸缪的新旧版本兼容，在使用此回调之前，需要将RCIM的showUnkownMessage设置为YES。
 比如，您App在新版本迭代中增加了某种自定义消息，当已经发布的旧版本不能识别，开发者可以在旧版本中预先定义好这些不能识别的消息的显示，
 如提示当前版本不支持，引导用户升级等。
 */
- (CTMSGMessageBaseCell *)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/*!
 未注册消息Cell显示的回调
 
 @param collectionView          当前CollectionView
 @param collectionViewLayout    当前CollectionView Layout
 @param indexPath               该Cell对应的消息Cell数据模型在数据源中的索引值
 @return                        未注册消息Cell需要显示的高度
 
 @discussion
 未注册消息的显示主要用于App未雨绸缪的新旧版本兼容，在使用此回调之前，需要将RCIM的showUnkownMessage设置为YES。
 比如，您App在新版本迭代中增加了某种自定义消息，当已经发布的旧版本不能识别，开发者可以在旧版本中预先定义好这些不能识别的消息的显示，
 如提示当前版本不支持，引导用户升级等。
 */
- (CGSize)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
                      sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - 点击事件回调

/*!
 点击Cell中的消息内容的回调
 
 @param model 消息Cell的数据模型
 
 @discussion SDK在此点击事件中，针对SDK中自带的图片、语音、位置等消息有默认的处理，如查看、播放等。
 您在重写此回调时，如果想保留SDK原有的功能，需要注意调用super。
 */
- (void)didTapMessageCell:(CTMSGMessageModel *)model;

/*!
 长按Cell中的消息内容的回调
 
 @param model 消息Cell的数据模型
 @param view  长按区域的View
 
 @discussion SDK在此长按事件中，会默认展示菜单。
 您在重写此回调时，如果想保留SDK原有的功能，需要注意调用super。
 */
- (void)didLongTouchMessageCell:(CTMSGMessageModel *)model inView:(UIView *)view;

/*!
 获取长按Cell中的消息时的菜单
 
 @param model 消息Cell的数据模型
 
 @discussion SDK在此长按事件中，会展示此方法返回的菜单。
 您在重写此回调时，如果想保留SDK原有的功能，需要注意调用super。
 */
- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(CTMSGMessageModel *)model;

/*!
 点击Cell中头像的回调
 
 @param userId  点击头像对应的用户ID
 */
- (void):(NSString *)userId;

#pragma mark - 语音消息、图片消息、位置消息、文件消息显示与操作

/*!
 开始录制语音消息的回调
 */
- (void)onBeginRecordEvent;

/*!
 结束录制语音消息的回调
 */
- (void)onEndRecordEvent;

/*!
 取消录制语音消息的回调(不会再走 onEndRecordEvent)
 */
- (void)onCancelRecordEvent;
/*!
 是否开启语音消息连续播放
 
 @discussion 如果设置为YES，在点击播放语音消息时，会将下面所有未播放过的语音消息依次播放。
 */
@property(nonatomic, assign) BOOL enableContinuousReadUnreadVoice;

/*!
 查看图片消息中的图片
 
 @param model   消息Cell的数据模型
 
 @discussion SDK在此方法中会默认调用RCImageSlideController下载并展示图片。
 */
- (void)presentImagePreviewController:(CTMSGMessageModel *)model;

/*!
 发送新拍照的图片完成之后，将图片在本地另行存储的回调
 
 @param newImage    图片
 
 @discussion 您可以在此回调中按照您的需求，将图片另行保存或执行其他操作。
 */
- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage;


#pragma mark - NS_UNAVAILABLE method

/*!
 更新导航栏返回按钮中显示的未读消息数
 
 @discussion 如果您重写此方法，需要注意调用super。
 */
- (void)notifyUpdateUnreadMessageCount NS_UNAVAILABLE;
/*!
 提示用户信息并推出当前会话界面
 
 @param errorInfo 错误提示
 
 @discussion 在聊天室加入失败SDK会调用此接口，提示用户并退出聊天室。如果您需要修改提示或者不退出，可以重写此方法。
 */
- (void)alertErrorAndLeft:(NSString *)errorInfo NS_UNAVAILABLE;

/*!
 返回前一个页面的方法
 
 @param sender 事件发起者
 
 @discussion 其中包含了一些会话页面退出的清理工作，如退出讨论组等。
 如果您重写此方法，请注意调用super。
 */
- (void)leftBarButtonItemPressed:(id)sender NS_UNAVAILABLE;


/*!
 点击Cell中URL的回调
 
 @param url   点击的URL
 @param model 消息Cell的数据模型
 */
- (void)didTapUrlInMessageCell:(NSString *)url model:(CTMSGMessageModel *)model NS_UNAVAILABLE;

/*!
 点击Cell中电话号码的回调
 
 @param phoneNumber 点击的电话号码
 @param model       消息Cell的数据模型
 */
- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(CTMSGMessageModel *)model NS_UNAVAILABLE;

/*!
 长按Cell中头像的回调
 
 @param userId  头像对应的用户ID
 */
- (void)didLongPressCellPortrait:(NSString *)userId NS_UNAVAILABLE;

/*!
 查看位置信息的位置详情
 
 @param locationMessageContent  点击的位置消息
 
 @discussion SDK在此方法中会默认调用RCLocationViewController在地图中展示位置。
 */
- (void)presentLocationViewController:(CTMSGLocationMessage *)locationMessageContent NS_UNAVAILABLE;

/*!
 查看文件消息中的文件
 
 @param model   消息Cell的数据模型
 
 @discussion SDK在此方法中会默认调用RCFilePreviewViewController下载并展示文件。
 */
- (void)presentFilePreviewViewController:(CTMSGMessageModel *)model NS_UNAVAILABLE;

#pragma mark - 公众号
///*!
// 点击公众号菜单
//
// @param selectedMenuItem  被点击的公众号菜单
// */
//- (void)onPublicServiceMenuItemSelected:(RCPublicServiceMenuItem *)selectedMenuItem;

///*!
// 点击公众号Cell中的URL的回调
//
// @param url   被点击的URL
// @param model 被点击的Cell对应的Model
// */
//- (void)didTapUrlInPublicServiceMessageCell:(NSString *)url model:(CTMSGMessageModel *)model;

//#pragma mark - 客服
///*!
// 用户的详细信息，此数据用于上传用户信息到客服后台，数据的nickName和portraitUrl必须填写。
// */
//@property(nonatomic, strong) RCCustomerServiceInfo *csInfo;

///*!
// 客服评价弹出时间，在客服页面停留超过这个时间，离开客服会弹出评价提示框，默认为60s
// */
//@property(nonatomic, assign) NSTimeInterval csEvaInterval;
///*!
// 评价客服服务,然后离开当前VC的。此方法有可能在离开客服会话页面触发，也可能是客服在后台推送评价触发，也可能用户点击机器人知识库评价触发。应用可以重写此方法来自定义客服评价界面。应用不要直接调用此方法。
//
// @param serviceStatus  当前的服务类型。
// @param commentId
// 评论ID。当是用户主动离开客服会话时，这个id是null；当客服在后台推送评价请求时，这个id是对话id；当用户点击机器人应答评价时，这个是机器人知识库id。
// @param isQuit         评价完成后是否离开
//
// @discussion
// sdk会在需要评价时调用此函数。如需自定义评价界面，请根据demo的RCDCustomerServiceViewController中的示例来重写此函数。
// */
//- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//                               commentId:(NSString *)commentId
//                        quitAfterComment:(BOOL)isQuit;

///*!
// 选择客服分组
// @param  groupList    所有客服分组
// @param  resultBlock  resultBlock
// @discussion
// 重写这个方法你可以自己重写客服分组界面，当用户选择技能组后，调用resultBlock传入用户选择分组的groupId，如果用户没有选择，可以传nil，会自动分配一个客服分组
// */
//- (void)onSelectCustomerServiceGroup:(NSArray *)groupList result:(void (^)(NSString *groupId))resultBlock;
//
///*!
// 离开客服界面
//
// @discussion 调用此方法离开客服VC。
// */
//- (void)customerServiceLeftCurrentViewController;

///*!
// 客服服务模式变化
//
// @param newMode  新的客服服务模式。
// */
//- (void)onCustomerServiceModeChanged:(CTMSGCSModeType)newMode;

/*!
 输入框内输入了@符号，即将显示选人界面的回调
 
 @param selectedBlock 选人后的回调
 @param cancelBlock   取消选人的回调
 
 @discussion
 开发者如果想更换选人界面，可以重写方法，弹出自定义的选人界面，选人结束之后，调用selectedBlock传入选中的UserInfo即可。
 */
- (void)showChooseUserViewController:(void (^)(CTMSGUserInfo *selectedUserInfo))selectedBlock
                              cancel:(void (^)(void))cancelBlock NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
