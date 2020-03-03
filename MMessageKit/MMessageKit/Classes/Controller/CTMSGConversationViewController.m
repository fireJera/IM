//
//  CTMSGConversationViewController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationViewController.h"
#import "CTMSGChatSessionInputBarControl.h"
#import "CTMSGPluginBoardView.h"
#import "CTMSGMessageModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <MessageLib/MessageLib.h>
#import "CTMSGChatCameraViewController.h"
#import "CTMSGAlbumListViewController.h"
#import "CTMSGAlbumManager.h"
#import "CTMSGPhotoModel.h"
#import "CTMSGEmojiBoardView.h"
#import "CTMSGTextMessageCell.h"
#import "CTMSGImageMessageCell.h"
#import "CTMSGVoiceMessageCell.h"
#import "CTMSGVideoMessageCell.h"
#import "CTMSGLocationMessageCell.h"
#import "CTMSGUnknownMessageCell.h"
#import "CTMSGTipMessageCell.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIImage+CTMSG_Cat.h"

#import "CTMSGUtilities.h"
#import "CTMSGIM.h"

#define LOCK dispatch_semaphore_wait(_dataLock, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_dataLock);

static const NSInteger loadMessageCountOneTime = 20;
static NSHashTable<CTMSGConversationViewController *> * _instancesMap = nil;
//static const int kPlugViewHeight = 180;

@interface CTMSGConversationViewController () <CTMSGChatSessionInputBarControlDelegate,
CTMSGAlbumListViewControllerDelegate, CTMSGMessageCellDelegate, CTMSGChatCameraDelegate> {
    NSInteger _pageNum;  // 第一次打开页面 = NO, 这时会在fetchfromdb自动滚动到底部， 之后不会再自动滚动到底部
    BOOL _didShowALL;   // 本地数据已经加载完毕，如果继续下拉不应该再从本地数据库读取
    BOOL _refreshing;   // 正在从本地或网络读取数据中，
    BOOL _viewDidAppear;   // 正在从本地或网络读取数据中，
}

@property (nonatomic, strong) dispatch_semaphore_t dataLock;
@property (nonatomic, strong) UIView * grayView;

@end

//TODO: - enabledReadReceiptConversationTypeList 根据类型判断是否回执已读

@implementation CTMSGConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewDidAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_ctmsg_receiveNewMsg:) name:CTMSGKitDispatchMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay:) name:kNotificationStopVoicePlayer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlay:) name:kNotificationPlayVoice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCellUpdateSendingStatusEvent:) name:KNotificationMessageBaseCellUpdateSendingStatus object:nil];
    
    _conversationDataRepository = [NSMutableArray array];
    
    [self p_ctmsg_setView];
    [self p_ctmsg_setInputBar];
    [self ctmsg_fetchMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
//    [_chatSessionInputBarControl containerViewWillAppear];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewDidAppear = YES;
//    [_chatSessionInputBarControl containerViewDidAppear];
//    if (!_hasScrolled) {
        //    [self ctmsg_fetchMessages];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    [self p_ctmsg_resetFrame];
//}

#pragma mark - set view
- (void)p_ctmsg_setView {
//    CGFloat selfWidth = CTMSGSCREENWIDTH;
//    CGFloat collectHeight = CTMSGSCREENHEIGHT - CTMSGNavBarHeight - CTMSGIphoneXBottomH - CTMSGInputNormalHeight;
    
    _customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    _customFlowLayout.estimatedItemSize = (CGSize){selfWidth, 100};
//    CGRectMake(0, 0, selfWidth, collectHeight)
    _conversationMessageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_customFlowLayout];
    _conversationMessageCollectionView.delegate = self;
    _conversationMessageCollectionView.dataSource = self;
    _conversationMessageCollectionView.backgroundColor = [UIColor ctmsg_colorE4E6EA];
    _conversationMessageCollectionView.showsVerticalScrollIndicator = NO;
    _conversationMessageCollectionView.showsHorizontalScrollIndicator = NO;
    _conversationMessageCollectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_conversationMessageCollectionView];
    [self registerClass:[CTMSGTextMessageCell class] forMessageClass:[CTMSGTextMessage class]];
    [self registerClass:[CTMSGImageMessageCell class] forMessageClass:[CTMSGImageMessage class]];
    [self registerClass:[CTMSGVoiceMessageCell class] forMessageClass:[CTMSGVoiceMessage class]];
    [self registerClass:[CTMSGVideoMessageCell class] forMessageClass:[CTMSGVideoMessage class]];
    [self registerClass:[CTMSGLocationMessageCell class] forMessageClass:[CTMSGLocationMessage class]];
    [self registerClass:[CTMSGUnknownMessageCell class] forMessageClass:[CTMSGUnknownMessage class]];
    [self registerClass:[CTMSGTipMessageCell class] forMessageClass:[CTMSGInformationNotificationMessage class]];
    if (@available(iOS 11.0, *)) {
        _conversationMessageCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _chatSessionInputBarControl = [[CTMSGChatSessionInputBarControl alloc] initWithFrame:CGRectMake(1000, 1000, 0, 0) withContainerView:self.view];
    _chatSessionInputBarControl.delegate = self;
    [self.view addSubview:_chatSessionInputBarControl];
    self.view.backgroundColor = [UIColor whiteColor];
    _didShowALL = NO;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_ctmsg_tapCollection:)];
    [_conversationMessageCollectionView addGestureRecognizer:tap];
//    [self p_ctmsg_resetFrame];
}

- (void)p_ctmsg_resetBarFrame:(CGRect)barFrame animated:(BOOL)animated {
    if (animated && _viewDidAppear) {
        [UIView animateWithDuration:0.25 animations:^{
            [self ctmsg_resetFrame:barFrame];
        }];
    } else {
        [self ctmsg_resetFrame:barFrame];
    }
}

- (void)ctmsg_resetFrame:(CGRect)barFrame {
    _chatSessionInputBarControl.frame = barFrame;
    CGFloat chatSessionTop = barFrame.origin.y;
    CGFloat collectHeight = self.view.frame.size.height - CTMSGNavBarHeight - CTMSGIphoneXBottomH - CTMSGInputNormalHeight;
    CGFloat collectTop = chatSessionTop - collectHeight;
    _conversationMessageCollectionView.frame = (CGRect){0, collectTop, self.view.frame.size.width, collectHeight};
    [_chatSessionInputBarControl setNeedsLayout];
    //    CGFloat bottomHeight = _chatSessionInputBarControl.height;
//    CGFloat top = _conversationMessageCollectionView.frame.size.height + _conversationMessageCollectionView.frame.origin.y;
}

- (void)p_ctmsg_setInputBar {
    _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
//    _chatSessionInputBarControl.defaultInputType = _defaultInputType;
}


- (void)ctmsg_fetchMessages {
//    [self willLoadNextPageMessage];
    if (_conversationDataRepository.count <= 0) {
        [self ctmsg_fetchDBMessage];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof(self) weakSelf = self;
        [self ctmsg_fetchNetMessage:^(NSArray<CTMSGMessage *> * _Nonnull serverMessages) {
            if (serverMessages) {
                [serverMessages enumerateObjectsUsingBlock:^(CTMSGMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CTMSGMessage * dbMessage = [[CTMSGIMClient sharedCTMSGIMClient] getMessageByUId:obj.messageUId];
                    if (!dbMessage) {
                        if (obj.messageDirection == CTMSGMessageDirectionSend) {
                            [[CTMSGIMClient sharedCTMSGIMClient] insertOutgoingMessage:ConversationType_PRIVATE targetId:obj.targetId messageUid:obj.messageUId sentStatus:SentStatus_SENT content:obj.content sentTime:obj.sentTime];
                        }
                        else {
                            [[CTMSGIMClient sharedCTMSGIMClient] insertIncomingMessage:ConversationType_PRIVATE targetId:obj.targetId messageUid:obj.messageUId senderUserId:obj.senderUserId receivedStatus:ReceivedStatus_READ content:obj.content sentTime:obj.sentTime];
                        }
                    }
                }];
            }
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf->_pageNum++;
            [weakSelf ctmsg_fetchDBMessage];
        }];
    });
}

- (void)ctmsg_fetchDBMessage {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    long msgId = 0;
    if (_pageNum <= 0) {
        [[CTMSGDataBaseManager shareInstance] updateAllMessageReadWithTargetId:_targetId];
        [_conversationDataRepository removeAllObjects];
    } else {
        if (_conversationDataRepository.count > 0) {
            msgId = _conversationDataRepository.firstObject.messageId;
        }
    }
    NSArray<CTMSGMessage *> *messages = [[CTMSGIMClient sharedCTMSGIMClient] getHistoryMessages:ConversationType_PRIVATE targetId:_targetId oldestMessageId:msgId count:loadMessageCountOneTime];
    [self p_ctmsg_insertNewDBMessage:messages];
    NSInteger topIndex = messages.count;
    [self p_ctmsg_refreshViewAfterFetchMessages:topIndex];
//    });
}

- (void)p_ctmsg_insertNewDBMessage:(NSArray<CTMSGMessage *> *)messages {
    [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CTMSGMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTMSGMessageModel * model = [[CTMSGMessageModel alloc] initWithMessage:obj];
        [_conversationDataRepository insertObject:model atIndex:0]; 
    }];
//    [messages enumerateObjectsUsingBlock:^(CTMSGMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    }];
    [self p_ctmsg_figureOutShowDisplayTime:messages.count];
}

- (void)ctmsg_fetchNetMessage:(void (^)(NSArray<CTMSGMessage *> * _Nullable))resultBlock {
    if (resultBlock) {
        resultBlock(nil);
    }
}

- (void)p_ctmsg_refreshViewAfterFetchMessages:(NSInteger)topIndex {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_conversationMessageCollectionView reloadData];
        _refreshing = NO;
        if (@available(iOS 10.0, *)) {
            [_conversationMessageCollectionView.refreshControl endRefreshing];
        }
        if (topIndex < loadMessageCountOneTime) {
            _didShowALL = YES;
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_pageNum <= 0) {
            [self scrollToBottomAnimated:NO];
        } else {
            if (self.conversationDataRepository.count > 0) {
                [_conversationMessageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:topIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
        }
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _conversationDataRepository.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    LOCK
    if (indexPath.row < _conversationDataRepository.count) {
        CTMSGMessageModel * messageModel = _conversationDataRepository[indexPath.row];
//        CTMSGMessageContent * message = messageModel.content;
//        UNLOCK
        NSString * identifier = [self customCellIdentifierForItemAtIndexPath:indexPath];
        if (identifier) {
            CTMSGMessageBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            cell.delegate = self;
            cell.model = [self customMessageoModelForItemAtIndexPath:indexPath];
            return cell;
        }
        CTMSGMessageBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:messageModel.objectName forIndexPath:indexPath];
        cell.delegate = self;
        cell.model = messageModel;
        return cell;
    } else {
//        UNLOCK
    }
    return [UICollectionViewCell new];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([cell isKindOfClass:[CTMSGMessageBaseCell class]]) {
    [self willDisplayMessageCell:(CTMSGMessageBaseCell *)cell atIndexPath:indexPath];
//    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
//    LOCK
    if (indexPath.row < _conversationDataRepository.count) {
        if ([self customCellIdentifierForItemAtIndexPath:indexPath]) {
            return [self customCellSizeForItemAtIndexPath:indexPath];
        }
        CTMSGMessageModel * message = _conversationDataRepository[indexPath.row];
        if (CGSizeEqualToSize(CGSizeZero, message.cellSize)) {
            [self p_ctmsg_culcalteCellSize:message];
//            message.cellSize = CGSizeMake(self.view.frame.size.width, 100);
        }
        size = message.cellSize;
    } else {
        size = CGSizeMake(self.view.frame.size.width, 100);
    }
//    UNLOCK
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [_chatSessionInputBarControl.inputTextView endEditing:YES];
    if (_chatSessionInputBarControl.currentBottomBarStatus != CTMSGBottomInputBarDefaultStatus &&
        _chatSessionInputBarControl.currentBottomBarStatus != CTMSGBottomInputBarLockStatus) {
        _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    BOOL subDidShowAll = [self didShowAllAfterLoadNextPageMessage];
    BOOL shouldLoad = !_didShowALL; // (subDidShowAll || !_didShowALL);
    if (!_refreshing && scrollView.contentOffset.y < 0 && shouldLoad) {
        _refreshing = YES;
        if (@available(iOS 10.0, *)) {
            [_conversationMessageCollectionView.refreshControl beginRefreshing];
        }
        [self ctmsg_fetchMessages];
    }
}

#pragma mark - CTMSGChatSessionInputBarControlDelegate

- (void)presentViewController:(UIViewController *)viewController functionTag:(NSInteger)functionTag {
    if ([viewController isKindOfClass:[CTMSGChatCameraViewController class]]) {
        ((CTMSGChatCameraViewController *)viewController).delegate = self;
    }
    else if ([viewController isKindOfClass:UINavigationController.class]) {
        UIViewController * album = ((UINavigationController *)viewController).topViewController;
        if ([album isKindOfClass:CTMSGAlbumListViewController.class]) {
            ((CTMSGAlbumListViewController *)album).delegate = self;
        }
    }
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)chatInputBar:(CTMSGChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame {
    [self p_ctmsg_resetBarFrame:frame animated:YES];
//    [self p_ctmsg_resetFrame];
}

- (void)inputTextViewDidTouchSendKey:(UITextView *)inputTextView {
    NSString * content = inputTextView.text;
    CTMSGTextMessage * textMessage = [CTMSGTextMessage messageWithContent:content];
    inputTextView.text = nil;
    [self sendMessage:textMessage pushContent:nil];
}

- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
}

- (void)pluginBoardView:(CTMSGPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    
}

- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchedEmoji:(NSString *)touchedEmoji {
    NSString * str = _chatSessionInputBarControl.inputTextView.text;
    str = [str stringByAppendingString:touchedEmoji];
    _chatSessionInputBarControl.inputTextView.text = str;
}

- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchSendButton:(UIButton *)sendButton {
    [self inputTextViewDidTouchSendKey:_chatSessionInputBarControl.inputTextView];
}

- (void)emojiViewRemoveEmoji:(CTMSGEmojiBoardView *)emojiView {
    NSString * str = _chatSessionInputBarControl.inputTextView.text;
    if (str.length) {
        NSRange range = [str rangeOfComposedCharacterSequenceAtIndex:str.length - 1];
        str = [str substringToIndex:range.location];
        _chatSessionInputBarControl.inputTextView.text = str;
    }
}

- (void)recordDidBegin {
    [self startPlay:nil];
    [self.view addSubview:self.grayView];
}

- (void)recordDidCancel:(BOOL)isTooShort {
    [self.grayView removeFromSuperview];
    if (isTooShort) {
        [self showCustomHud:@"按键时间太短"];
    }
}

- (void)recordDidEnd:(NSData *)recordData recordPath:(NSString *)path duration:(long)duration error:(NSError *)error {
    [self.grayView removeFromSuperview];
    if (!recordData || recordData.length == 0) return;
//    NSData * wavData = [NSData dataWithContentsOfFile:path];
//    if (!wavData || wavData.length == 0) return;
    CTMSGVoiceMessage * message = [CTMSGVoiceMessage messageWithAudio:recordData duration:duration localURL:path];
    [self sendMediaMessage:message pushContent:nil appUpload:_customUpload];
}

- (void)pickImages:(NSArray<UIImage *> *)images {
    _chatSessionInputBarControl.currentBottomBarStatus = CTMSGChatSessionInputBarControlDefaultType;
//    NSMutableArray<CTMSGImageMessage *>* imageMessages = [NSMutableArray array];
    float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
    parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
//    NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_image.png", parentPath, nowTime];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
        NSLog(@"%@",parentPath);
        [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
//    NSData * data = UIImagePNGRepresentation(image);
//    [data writeToFile:filePath atomically:YES];
    
    [self prepareWorkForSendImagesMessagesTask:^(BOOL shouldSend) {
        if (shouldSend) {
            [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_%d_image.png", parentPath, nowTime, (int)idx];
                NSData * data = UIImagePNGRepresentation(obj);
                [data writeToFile:filePath atomically:YES];
                CTMSGImageMessage * imageMessage = [CTMSGImageMessage messageWithImage:obj imageURI:filePath];
                [self sendMediaMessage:imageMessage pushContent:nil appUpload:_customUpload];
            }];
        }
        [self finishWorkForSendImagesMessages];
    }];
}

- (void)pickNumBeyondMax {
    [self showCustomHud:@"最多选9张"];
}

- (void)imageDidCapture:(UIImage *)image {
    float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
    parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_image.png", parentPath, nowTime];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
        NSLog(@"%@",parentPath);
        [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToFile:filePath atomically:YES];
    
    CTMSGImageMessage * message = [CTMSGImageMessage messageWithImage:image imageURI:filePath];
    [self sendMediaMessage:message pushContent:nil appUpload:_customUpload];
}

- (void)sightDidFinishRecord:(NSString *)url thumbnail:(UIImage *)image duration:(NSUInteger)duration {
    if (!image) {
        image = [UIImage ctmsg_imageInLocalPath:url];
    }
    if (duration == 0) {
        AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:url]];
        CMTime time = [asset duration];
        duration = (NSUInteger)(time.value/time.timescale);
    }
    CTMSGVideoMessage * videoMessage = [CTMSGVideoMessage messageWithLocalPath:url image:image];
    [self sendMediaMessage:videoMessage pushContent:nil appUpload:_customUpload];
}

#pragma mark - CTMSGChatCameraDelegate

- (void)ctmsg_cameraPhotoTaked:(CTMSGChatCameraViewController *)controller image:(UIImage *)image {
    [self imageDidCapture:image];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

//- (void)ctmsg_cameraVideoTaked:(CTMSGChatCameraViewController *)controller videoPath:(NSString *)videoPath {
//    [self sightDidFinishRecord:videoPath thumbnail:nil duration:0];
//    [controller dismissViewControllerAnimated:YES completion:nil];
//}

- (void)ctmsg_cancelCamera:(CTMSGChatCameraViewController *)controller {
    
}

#pragma mark - CTMSGAlbumListViewControllerDelegate

- (void)albumListViewControllerDidFinish:(CTMSGAlbumListViewController *)albumListViewController {
    [albumListViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
    parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
    //    NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_image.png", parentPath, nowTime];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
        NSLog(@"%@",parentPath);
        [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [albumListViewController.albumManager.selectedList enumerateObjectsUsingBlock:^(CTMSGPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CTMSGPhotoModelMediaTypePhoto ||
            obj.type == CTMSGPhotoModelMediaTypeGif ||
            obj.type == CTMSGPhotoModelMediaTypeLive) {
            [CTMSGUtilities fetchImage:obj.asset image:^(UIImage * _Nonnull image) {
                NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_%d_image.png", parentPath, nowTime, (int)idx];
                NSData * data = UIImagePNGRepresentation(image);
                [data writeToFile:filePath atomically:YES];
                CTMSGImageMessage * imageMessage = [CTMSGImageMessage messageWithImage:image imageURI:filePath];
                [self sendMediaMessage:imageMessage pushContent:nil appUpload:_customUpload];
            }];
        }
//        else if (obj.type == CTMSGPhotoModelMediaTypeVideo) {
//            [CTMSGUtilities convertAsset:obj.asset finished:^(NSError * _Nullable error, NSString * _Nullable videoPath) {
//                if (!error) {
//                    UIImage * cover = [UIImage ctmsg_imageInLocalPath:videoPath];
//                    CTMSGVideoMessage * videoMessage = [CTMSGVideoMessage messageWithLocalPath:videoPath image:cover];
//                    [self sendMediaMessage:videoMessage pushContent:nil appUpload:_customUpload];
//                } else {
//                    NSDictionary *dic = error.userInfo;
//                    NSLog(@"send video message error:%@", dic[NSLocalizedDescriptionKey]);
//                    [self showCustomHud:dic[NSLocalizedDescriptionKey]];
//                }
//            }];
//        }
    }];
}

- (void)albumListViewControllerDidCancel:(CTMSGAlbumListViewController *)albumListViewController {
    
}

#pragma mark - touch event

- (void)p_ctmsg_clickWechat:(UIBarButtonItem *)sender {
    
}

- (void)p_ctmsg_clickAvatar:(UIButton *)sender {
    
}

- (void)p_ctmsg_tapCollection:(UITapGestureRecognizer *)tap {
    if (_chatSessionInputBarControl.currentBottomBarStatus == CTMSGBottomInputBarLockStatus ||
        _chatSessionInputBarControl.currentBottomBarStatus == CTMSGBottomInputBarDefaultStatus) return;
    _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
}

#pragma mark - notification

- (void)keyboardWillShow:(NSNotification *)notificaiton {
    NSDictionary *info = notificaiton.userInfo;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (_chatSessionInputBarControl.keyboardHeight == 0) {
        _chatSessionInputBarControl.keyboardHeight = kbSize.height - CTMSGIphoneXBottomH;
        _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarKeyboardStatus;
    } else {
        _chatSessionInputBarControl.keyboardHeight = kbSize.height - CTMSGIphoneXBottomH;
    }
//    [self p_ctmsg_resetFrame];
}

//- (void)keyboardDidShow:(NSNotification *)notificaiton {
//    if (_chatSessionInputBarControl.currentBottomBarStatus != CTMSGBottomInputBarKeyboardStatus) {
//        _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarKeyboardStatus;
//    }
//}

- (void)keyboardWillHide:(NSNotification *)notificaiton {
    if (_chatSessionInputBarControl.currentBottomBarStatus == CTMSGBottomInputBarKeyboardStatus) {
        _chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
    }
}

- (void)p_ctmsg_receiveNewMsg:(NSNotification *)notificaiton {
    CTMSGMessage * message = notificaiton.object;
    if ([message.targetId isEqualToString:_targetId]) {
        BOOL supportMessage = YES;
        if (supportMessage) {
            [self appendAndDisplayMessage:message];
        } else {
            if ([CTMSGIM sharedCTMSGIM].showUnkownMessage) {
                
            }
        }
        [[CTMSGDataBaseManager shareInstance] updateSingleMessageReadWithMessageId:@(message.messageId).stringValue];
    }
}

- (void)startPlay:(NSNotification *)notification {
    [_conversationMessageCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:CTMSGVoiceMessageCell.class]) {
            [(CTMSGVoiceMessageCell *)obj stopPlayVoice];
        }
    }];
}

- (void)stopPlay:(NSNotification *)notification {
    CTMSGMessageModel * model = notification.object;
    if (model.messageDirection == CTMSGMessageDirectionSend) {
        return;
    }
    __block  NSIndexPath * indexPath;
    __block BOOL finded = NO;
    if (_enableContinuousReadUnreadVoice) {
        [_conversationDataRepository enumerateObjectsUsingBlock:^(CTMSGMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == model) {
                finded = YES;
            }
            if (finded) {
                if ([[obj objectName] isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
                    indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    *stop = YES;
                }
            }
        }];
    }
    if (indexPath) {
        CTMSGVoiceMessageCell * cell = (CTMSGVoiceMessageCell *)[_conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[CTMSGVoiceMessageCell class]]) {
            [cell playVoice];
        }
    }
}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    NSDictionary * dic = notification.object;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        long messageId = [dic[@"messageId"] longValue];
        CTMSGSentStatus status = [dic[@"status"] unsignedIntegerValue];
        [_conversationDataRepository enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CTMSGMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.messageId == messageId) {
                obj.sentStatus = status;
                *stop = YES;
            }
        }];
        [_conversationMessageCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof CTMSGMessageBaseCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.model.messageId == messageId) {
//                obj.model.sentStatus = status;
                [obj messageCellUpdateSendingStatusEvent:notification];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - public

+ (BOOL)conversationOpenedWithTargetId:(NSString *)targetId {
    NSEnumerator * enumerator = [_instancesMap objectEnumerator];
    CTMSGConversationViewController * conversation;
    while (conversation = [enumerator nextObject]) {
        if ([conversation.targetId isEqualToString:targetId]) {
            return YES;
        }
    }
    return NO;
}

//- (void)willLoadNextPageMessage {}

- (BOOL)didShowAllAfterLoadNextPageMessage {
    return _didShowALL;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger item = _conversationDataRepository.count - 1;
    if (item <= 0) return;
    NSIndexPath * lastItemIndex = [NSIndexPath indexPathForItem:item inSection:0];
    [_conversationMessageCollectionView scrollToItemAtIndexPath:lastItemIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
}

- (NSString *)customCellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CTMSGMessageModel *)customMessageoModelForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)customCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

- (void)sendMessage:(CTMSGMessageContent *)messageContent pushContent:(NSString *)pushContent {
    [self willSendMessage:messageContent];
//    CTMSGMessage * message = [[CTMSGMessage alloc] init];
//    [self willAppendAndDisplayMessage:message];
    [[CTMSGIM sharedCTMSGIM] sendMessage:_conversationType
                                targetId:_targetId
                                 content:messageContent
                             pushContent:pushContent
                                pushData:nil
                                 success:^(long messageId) {
                                     [self didSendMessage:messageId
                                                  content:messageContent];
                                 } error:^(CTMSGErrorCode nErrorCode, long messageId, NSError * _Nullable error) {
                                     [self showCustomHud:error.localizedDescription];
                                 }];
}

- (void)sendMediaMessage:(CTMSGMessageContent *)messageContent pushContent:(NSString *)pushContent appUpload:(BOOL)appUpload {
    [self willSendMessage:messageContent];
    if (appUpload) {
        __block CTMSGUploadMediaStatusListener * listener = nil;
        CTMSGMessage * message = [[CTMSGIMClient sharedCTMSGIMClient] sendMediaMessage:_conversationType targetId:_targetId content:messageContent pushContent:pushContent pushData:nil uploadPrepare:^(CTMSGUploadMediaStatusListener * _Nonnull uploadListener) {
            listener = uploadListener;
        } progress:^(int progress, long messageId) {
            NSDictionary * dic = @{
                                   @"messageId": @(messageId),
                                   @"status": @(SentStatus_SENDING),
                                   @"progress": @(progress),
                                   };
//            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
//                if (progressBlock) {
//                    progressBlock(progress, messageId);
//                }
//            });
        } success:^(long messageId) {
            NSDictionary * dic = @{
                                   @"messageId": @(messageId),
                                   @"status": @(SentStatus_SENT)
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
        } error:^(CTMSGErrorCode errorCode, long messageId, NSError * error) {
            NSDictionary * dic = @{
                                   @"messageId": @(messageId),
                                   @"status": @(SentStatus_FAILED)
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
            [self showCustomHud:error.localizedDescription];
        } cancel:^(long messageId) {
            NSDictionary * dic = @{
                                   @"messageId": @(messageId),
                                   @"status": @(SentStatus_CANCELED)
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
        }];
        [self uploadMedia:message uploadListener:listener];
    }
    else {
        [[CTMSGIM sharedCTMSGIM] sendMediaMessage:_conversationType
                                         targetId:_targetId
                                          content:messageContent
                                      pushContent:pushContent
                                         pushData:nil
                                     uploadConfig:nil //_viewInfo.ossConfig
                                         progress:^(int progress, long messageId) {
            
        } success:^(long messageId) {
            
        } error:^(CTMSGErrorCode errorCode, long messageId, NSError * _Nullable error) {
            [self showCustomHud:error.localizedDescription];
        } cancel:^(long messageId) {
            
        }];
    }
}

- (void)prepareWorkForSendImagesMessagesTask:(void (^)(BOOL))task {
    if (task) {
        task(YES);
    }
}

- (void)finishWorkForSendImagesMessages {
    
}

- (void)uploadMedia:(CTMSGMessage *)message uploadListener:(CTMSGUploadMediaStatusListener *)uploadListener {
    [self appendAndDisplayMessage:message];
}

- (void)cancelUploadMedia:(CTMSGMessageModel *)model {
    
}

- (void)resendMessage:(CTMSGMessageModel *)model {
    long messageId = model.messageId;
    
    if (messageId > 0) {
        [[CTMSGDataBaseManager shareInstance] removeMessageWithId:messageId];
        [_conversationDataRepository removeObject:model];
        [_conversationMessageCollectionView reloadData];
    }
    if ([model.content isKindOfClass:CTMSGTextMessage.class]) {
        CTMSGTextMessage * textMessage = (CTMSGTextMessage *)model.content;
        [self sendMessage:textMessage pushContent:nil];
    }
    else if ([model.content isKindOfClass:CTMSGVoiceMessage.class]) {
        CTMSGVoiceMessage * voiceMessage = (CTMSGVoiceMessage *)model.content;
        [self sendMediaMessage:voiceMessage pushContent:nil appUpload:_customUpload];
    }
    else if ([model.content isKindOfClass:CTMSGImageMessage.class]) {
        CTMSGImageMessage * imageMessage = (CTMSGImageMessage *)model.content;
        [self sendMediaMessage:imageMessage pushContent:nil appUpload:_customUpload];
    }
//    else if ([model.content isKindOfClass:CTMSGVideoMessage.class]) {
//        CTMSGVideoMessage * videoMessage = (CTMSGVideoMessage *)model.content;
//        [self sendMediaMessage:videoMessage pushContent:nil appUpload:_customUpload];
//    }
}

- (void)appendAndDisplayMessage:(CTMSGMessage *)message {
    CTMSGMessage * appendMessage = [self willAppendAndDisplayMessage:message];
    if (appendMessage && _conversationDataRepository) {
//        LOCK
//        UNLOCK
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger count = _conversationDataRepository.count;
            CTMSGMessageModel *model = [[CTMSGMessageModel alloc] initWithMessage:appendMessage];
            [_conversationDataRepository addObject:model];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:count inSection:0];
            [_conversationMessageCollectionView insertItemsAtIndexPaths:@[indexPath]];
            if (message.messageDirection == CTMSGMessageDirectionReceive) {
                if (_conversationMessageCollectionView.contentOffset.y >= _conversationMessageCollectionView.contentSize.height - _conversationMessageCollectionView.bounds.size.height * 2) {
                    [_conversationMessageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
                }
            } else {
                [_conversationMessageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            }
        });
    }
}

- (void)deleteMessage:(CTMSGMessageModel *)model {
    
}

- (void)recallMessage:(long)messageId {
    
}

- (CTMSGMessageContent *)willSendMessage:(CTMSGMessageContent *)messageContent {
    return messageContent;
}

- (void)didSendMessage:(NSInteger)status content:(CTMSGMessageContent *)messageContent {
    
}

- (void)didCancelMessage:(CTMSGMessageContent *)messageContent {
    
}

- (CTMSGMessage *)willAppendAndDisplayMessage:(CTMSGMessage *)message {
    __block CTMSGMessage * returnMessage = message;
    [_conversationDataRepository enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CTMSGMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.messageId == message.messageId) {
            returnMessage = nil;
            CTMSGMessageModel *model = [[CTMSGMessageModel alloc] initWithMessage:message];
            [self p_ctmsg_culcalteCellSize:model];
            [_conversationDataRepository replaceObjectAtIndex:idx withObject:model];
            [_conversationMessageCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
            *stop = YES;
        }
    }];
    return returnMessage;
}

- (void)willDisplayMessageCell:(CTMSGMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)registerClass:(Class)cellClass forMessageClass:(Class)messageClass {
    NSParameterAssert(cellClass && messageClass);
    if (!cellClass || !messageClass) {
        return;
    }
    //TODO: - save message class if not support messageClass show unknowmessage
    NSString * str;
    if ([messageClass respondsToSelector:@selector(getObjectName)]) {
        str = [messageClass getObjectName];
    }
    [_conversationMessageCollectionView registerClass:cellClass forCellWithReuseIdentifier:str];
}

- (CTMSGMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

- (CTMSGMessageBaseCell *)rcUnkownConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)rcUnkownConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

- (void)didTapMessageCell:(CTMSGMessageModel *)model {
    
}

- (void)didLongTouchMessageCell:(CTMSGMessageModel *)model inView:(UIView *)view {
    [view becomeFirstResponder];
    UIMenuController * menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) return;
    NSArray * items = [self getLongTouchMessageCellMenuList:model];
    menu.menuItems = items;
    [menu setTargetRect:(CGRect){CGPointZero, view.frame.size} inView:view];
    [menu setMenuVisible:YES animated:YES];
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(CTMSGMessageModel *)model {
    NSMutableArray * array = [NSMutableArray array];
    if ([model.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
        UIMenuItem * item = [[UIMenuItem alloc] initWithTitle:@"复制" action:NSSelectorFromString(@"p_copy:")];
        [array addObject:item];
    }
    else if ([model.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
        
    }
    else if ([model.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
        
    }
    else if ([model.objectName isEqualToString:CTMSGUnknownMessageTypeIdentifier]) {
        
    }
    UIMenuItem * item = [[UIMenuItem alloc] initWithTitle:@"删除" action:NSSelectorFromString(@"p_delete:")];
    [array addObject:item];
    return [array copy];
}

- (void)didTapMessageCellMenuCopy:(CTMSGMessageModel *)model {
    if ([model.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
        [[UIPasteboard generalPasteboard] setString:((CTMSGTextMessage *)model.content).content];
    }
}

- (void)didTapMessageCellMenuDelete:(CTMSGMessageModel *)model {
    [self deleteMessage:model];
}

- (void)didTapCellPortrait:(NSString *)userId {
    
}

- (void)onBeginRecordEvent {
    
}

- (void)onEndRecordEvent {
    
}

- (void)onCancelRecordEvent {
    
}

- (void)presentImagePreviewController:(CTMSGMessageModel *)model {
    
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
    UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
//        [self showTextHUD:@"保存成功" withEnabled:YES];
    } else {
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    }
}

//- (CTMSGEmojiBoardView *)board {
//    return <#expression#>;
//}
#pragma mark - private

- (void)p_ctmsg_figureOutShowDisplayTime:(NSInteger)count {
    NSInteger msgCount = self.conversationDataRepository.count;
    NSInteger totalCount = msgCount <= loadMessageCountOneTime ? msgCount : count + 1;
    
    for (int i = 0; i < totalCount; i++) {
        CTMSGMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
//            CGSize size = model.cellSize;
//            size.height = model.cellSize.height + CTMSGMessageCellTimeZoneHeight;
//            model.cellSize = size;
        } else if (i > 0) {
            CTMSGMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
            long long previous_time = pre_model.sentTime;
            long long current_time = model.sentTime;
            
            long long interval =
            current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            if (interval / 1000 <= 3 * 60) {
//                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height - CTMSGMessageCellTimeZoneHeight;
//                    model.cellSize = size;
//                }
                model.isDisplayMessageTime = NO;
            }
            else {
//                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
//                    CGSize size = model.cellSize;
//                    size.height = model.cellSize.height + CTMSGMessageCellTimeZoneHeight;
//                    model.cellSize = size;
//                }
                model.isDisplayMessageTime = YES;
            }
        }
    }
}

- (void)p_ctmsg_culcalteCellSize:(CTMSGMessageModel *)model {
    CGFloat width = CTMSGSCREENWIDTH;
    CGFloat extraHeight = 20 + (model.isDisplayMessageTime ? CTMSGMessageCellTimeZoneHeight : 0);
    if ([model.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
        model.cellSize = [CTMSGTextMessageCell sizeForMessageModel:model
                                           withCollectionViewWidth:width
                                              referenceExtraHeight:extraHeight];
    }
    else if ([model.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
        model.cellSize = [CTMSGImageMessageCell sizeForMessageModel:model
                                            withCollectionViewWidth:width
                                               referenceExtraHeight:extraHeight];
    }
    else if ([model.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
        model.cellSize = [CTMSGVoiceMessageCell sizeForMessageModel:model
                                            withCollectionViewWidth:width
                                               referenceExtraHeight:extraHeight];
    }
    else if ([model.objectName isEqualToString:CTMSGVideoMessageTypeIdentifier]) {
        model.cellSize = [CTMSGVideoMessageCell sizeForMessageModel:model
                                            withCollectionViewWidth:width
                                               referenceExtraHeight:extraHeight];
    }
    else if ([model.objectName isEqualToString:CTMSGUnknownMessageTypeIdentifier]) {
        model.cellSize = [CTMSGUnknownMessageCell sizeForMessageModel:model
                                              withCollectionViewWidth:width
                                                 referenceExtraHeight:extraHeight];
    }
}

//- (void)p_ctmsg_removeMessage:(UIMenuController *)menu {
//
//}
//
//- (void)p_ctmsg_copyMessage:(UIMenuController *)menu {
//
//}

#pragma mark - lazy

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [[UIView alloc] initWithFrame:_conversationMessageCollectionView.frame];
        _grayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _grayView;
}

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_ctmsg_saveInstance];
    }
    return self;
}

- (instancetype)initWithConversationType:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    self = [super init];
    if (!self) return nil;
#if DEBUG
    NSParameterAssert(targetId);
#else
    if (!targetId) {
        return nil;
    }
#endif
    _conversationType = conversationType;
    _targetId = targetId;
    [self p_ctmsg_saveInstance];
    return self;
}

- (void)p_ctmsg_saveInstance {
    _pageNum = -1;
    _dataLock = dispatch_semaphore_create(1);
    _customUpload = NO;
//    _showHeadInfo = NO;
    if (!_instancesMap) {
        _instancesMap = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    [_instancesMap addObject:self];
}

- (void)showCustomHud:(NSString *)text {
    if (!text || text.length == 0) return;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UILabel * label = [[UILabel alloc] init];
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    UIFont * labelFont = [UIFont systemFontOfSize:14];
    label.font = labelFont;
    label.textColor = [UIColor whiteColor];
    CGFloat maxWidth = self.view.frame.size.width - 80;
    
    CGRect textRect = [text
                       boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                       options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                NSStringDrawingUsesFontLeading)
                       attributes:@{NSFontAttributeName : labelFont}
                       context:nil];
    
    CGSize labelSize = textRect.size;
    const CGFloat leading = 10, trailling = 10;
    label.frame = (CGRect){leading, trailling, labelSize};
    view.layer.cornerRadius = 4;
    labelSize = (CGSize){labelSize.width + leading * 2, labelSize.height + trailling * 2};
    view.frame = (CGRect){(self.view.frame.size.width - label.frame.size.width) / 2, (self.view.frame.size.height - label.frame.size.height - 200), labelSize};
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
    });
}

#pragma mark - runtime

//+ (BOOL)resolveClassMethod:(SEL)sel {
//    return NO;
//}
//
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return nil;
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    if ([NSStringFromSelector(aSelector) isEqualToString:@"updateForMessageSendOut:"]) {
//        NSMethodSignature *signature = [[self class] methodSignatureForSelector:@selector(updateForMessageSendOut:)];
//        return signature;
//    }
//    return [super methodSignatureForSelector:aSelector];
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
////    SEL sel = anInvocation.selector;
//    [anInvocation invokeWithTarget:[self class]];
//}

+ (void)updateForMessageSendOut:(CTMSGMessage *)message {
    NSEnumerator * enumerator = [_instancesMap objectEnumerator];
    CTMSGConversationViewController * conversation;
    while (conversation = [enumerator nextObject]) {
        if ([conversation.targetId isEqualToString:message.targetId]) {
            [conversation appendAndDisplayMessage:message];
        }
    }
}

+ (NSHashTable<CTMSGConversationViewController *> *)allInstance {
    return _instancesMap;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
