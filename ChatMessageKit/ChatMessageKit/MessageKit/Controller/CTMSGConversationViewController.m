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
#import "CTMSGMessageContent.h"
#import "CTMSGMessage.h"
#import "CTMSGUploadMediaStatusListener.h"
#import "CTMSGIMClient.h"
#import "CTMSGChatCameraViewController.h"
#import "CTMSGEmojiBoardView.h"

#import "CTMSGTextMessageCell.h"
#import "CTMSGImageMessageCell.h"
#import "CTMSGVoiceMessageCell.h"
#import "CTMSGLocationMessageCell.h"
#import "CTMSGUnknownMessageCell.h"
#import "CTMSGTipMessageCell.h"
#import "CTMSGTextMessage.h"
#import "CTMSGImageMessage.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGVideoMessage.h"
#import "CTMSGLocationMessage.h"
#import "CTMSGUnknownMessage.h"
#import "CTMSGInformationNotificationMessage.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

#import "CTMSGUtilities.h"
#import "CTMSGIM.h"

#define LOCK dispatch_semaphore_wait(_dataLock, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_dataLock);

//static const int kPlugViewHeight = 180;

@interface CTMSGConversationViewController () <CTMSGChatSessionInputBarControlDelegate, CTMSGChatCameraDelegate>
//{
//    BOOL _inputing;
//}

@property (nonatomic, strong) dispatch_semaphore_t dataLock;

@end

//TODO: - enabledReadReceiptConversationTypeList 根据类型判断是否回执已读

@implementation CTMSGConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_ctmsg_receiveNewMsg:) name:CTMSGKitDispatchMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay:) name:kNotificationStopVoicePlayer object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPlay:) name:kNotificationPlayVoice object:nil];
    [self p_ctmsg_setView];
    [self p_ctmsg_setInputBar];
    [self p_ctmsg_setdata];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [_chatSessionInputBarControl containerViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_chatSessionInputBarControl containerViewDidAppear];
}

- (void)viewDidLayoutSubviews {
    CGFloat bottomHeight = _chatSessionInputBarControl.height;
    CGFloat collectHeight = self.view.frame.size.height - bottomHeight - CTMSGIphoneXBottomH;
    _conversationMessageCollectionView.frame = (CGRect){0, 0, self.view.frame.size.width, collectHeight};
    _chatSessionInputBarControl.frame = (CGRect){0, collectHeight, self.view.frame.size.width, bottomHeight};
}

#pragma mark - set view
- (void)p_ctmsg_setView {
    self.view.backgroundColor = [UIColor whiteColor];
//    CGFloat selfWidth = CTMSGSCREENWIDTH;
    _customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    _customFlowLayout.estimatedItemSize = (CGSize){selfWidth, 100};
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
    [self registerClass:[CTMSGLocationMessageCell class] forMessageClass:[CTMSGLocationMessage class]];
    [self registerClass:[CTMSGUnknownMessageCell class] forMessageClass:[CTMSGUnknownMessage class]];
    [self registerClass:[CTMSGTipMessageCell class] forMessageClass:[CTMSGInformationNotificationMessage class]];
//    if (@available(iOS 11.0, *)) {
//        _conversationMessageCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    _chatSessionInputBarControl = [[CTMSGChatSessionInputBarControl alloc] initWithFrame:CGRectZero
                                                                       withContainerView:self.view
                                                                             controlType:CTMSGChatSessionInputBarControlDefaultType
                                                                        defaultInputType:CTMSGChatSessionInputBarInputTypeText];
    _chatSessionInputBarControl.delegate = self;
    [self.view addSubview:_chatSessionInputBarControl];
}

- (void)p_ctmsg_setInputBar {
    _chatSessionInputBarControl.defaultInputType = _defaultInputType;
}

- (void)p_ctmsg_setdata {
    _conversationDataRepository = [NSMutableArray array];
    NSArray<CTMSGMessage *> *messages = [[CTMSGIMClient sharedCTMSGIMClient] getLatestMessages:ConversationType_PRIVATE
                                                  targetId:_targetId
                                                     count:20];
    CGFloat width = CTMSGSCREENWIDTH;
    [messages enumerateObjectsUsingBlock:^(CTMSGMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTMSGMessageModel * model = [[CTMSGMessageModel alloc] initWithMessage:obj];
        if ([model.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
            model.cellSize = [CTMSGTextMessageCell sizeForMessageModel:model
                                               withCollectionViewWidth:width
                                                  referenceExtraHeight:20];
        }
        else if ([model.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
            model.cellSize = [CTMSGImageMessageCell sizeForMessageModel:model
                                               withCollectionViewWidth:width
                                                  referenceExtraHeight:20];
        }
        else if ([model.objectName isEqualToString:CTMSGVoiceMessageTypeIdentifier]) {
            model.cellSize = [CTMSGVoiceMessageCell sizeForMessageModel:model
                                               withCollectionViewWidth:width
                                                  referenceExtraHeight:20];
        }
//        else if ([model.objectName isEqualToString:CTMSGVideoMessageTypeIdentifier]) {
//            model.cellSize = [CTMSGVideoMessageCell sizeForMessageModel:model
//                                               withCollectionViewWidth:width
//                                                  referenceExtraHeight:65];
//        }
        [_conversationDataRepository addObject:model];
    }];
    [self p_ctmsg_figureOutShowDisplayTime];
    _dataLock = dispatch_semaphore_create(1);
    [_conversationMessageCollectionView reloadData];
//    _inputing = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 10;
    return _conversationDataRepository.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LOCK
    if (indexPath.row < _conversationDataRepository.count) {
        CTMSGMessageModel * messageModel = _conversationDataRepository[indexPath.row];
//        CTMSGMessageContent * message = messageModel.content;
        UNLOCK
        CTMSGMessageBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:messageModel.objectName forIndexPath:indexPath];
        cell.model = messageModel;
        return cell;
    } else {
        UNLOCK
    }
    return [UICollectionViewCell new];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CTMSGMessageBaseCell class]]) {
        [self willDisplayMessageCell:(CTMSGMessageBaseCell *)cell atIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LOCK
    if (indexPath.row < _conversationDataRepository.count) {
        CTMSGMessageModel * message = _conversationDataRepository[indexPath.row];
        [self didTapMessageCell:message];
    }
    UNLOCK
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    LOCK
    if (indexPath.row < _conversationDataRepository.count) {
        CTMSGMessageModel * message = _conversationDataRepository[indexPath.row];
        if (CGSizeEqualToSize(CGSizeZero, message.cellSize)) {
//            CTMSGMessageBaseCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
//            message.cellSize = [[cell class] sizeForMessageModel:message withCollectionViewWidth:_conversationMessageCollectionView.bounds.size.width referenceExtraHeight:40];
            message.cellSize = CGSizeMake(self.view.frame.size.width, 100);
        }
        size = message.cellSize;
    } else {
        size = CGSizeMake(self.view.frame.size.width, 100);
    }
    UNLOCK
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [_chatSessionInputBarControl.inputTextView endEditing:YES];
}

#pragma mark - CTMSGChatSessionInputBarControlDelegate

- (void)presentViewController:(UIViewController *)viewController functionTag:(NSInteger)functionTag {
    if ([viewController isKindOfClass:[CTMSGChatCameraViewController class]]) {
        ((CTMSGChatCameraViewController *)viewController).delegate = self;
    }
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)chatInputBar:(CTMSGChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame {
    [self.view setNeedsLayout];
}

- (void)inputTextViewDidTouchSendKey:(UITextView *)inputTextView {
    
}

- (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
}

- (void)pluginBoardView:(CTMSGPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    
}

- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchedEmoji:(NSString *)touchedEmoji {
    NSString * str = _chatSessionInputBarControl.inputTextView.text;
    str = [str stringByAppendingString:touchedEmoji];
    _chatSessionInputBarControl.inputTextView.text = str;
    [emojiView enableSendButton:YES];
    [_chatSessionInputBarControl containerViewSizeChanged];
}

- (void)emojiView:(CTMSGEmojiBoardView *)emojiView didTouchSendButton:(UIButton *)sendButton {
    
}

- (void)emojiViewRemoveEmoji:(CTMSGEmojiBoardView *)emojiView {
    NSString * str = _chatSessionInputBarControl.inputTextView.text;
    if (str.length) {
        NSRange range = [str rangeOfComposedCharacterSequenceAtIndex:str.length-1];
        str = [str substringToIndex:range.location];
        _chatSessionInputBarControl.inputTextView.text = str;
        if (str.length == 0) {
            [emojiView enableSendButton:NO];
        }
        [_chatSessionInputBarControl containerViewSizeChanged];
    }
}

- (void)recordDidBegin {
    
}

- (void)recordDidCancel {
    
}

- (void)recordDidEnd:(NSData *)recordData recordPath:(NSString *)path duration:(long)duration error:(NSError *)error {
    if (!recordData || recordData.length == 0) return;
//    NSData * wavData = [NSData dataWithContentsOfFile:path];
//    if (!wavData || wavData.length == 0) return;
    CTMSGVoiceMessage * message = [CTMSGVoiceMessage messageWithAudio:recordData duration:duration];
    [[CTMSGIM sharedCTMSGIM] sendMediaMessage:ConversationType_PRIVATE
                                     targetId:_targetId
                                      content:message
                                  pushContent:nil
                                     pushData:nil
                                     progress:^(int progress, long messageId) {
                                         
                                     } success:^(long messageId) {
                                         
                                     } error:^(CTMSGErrorCode errorCode, long messageId) {
                                         
                                     } cancel:^(long messageId) {
                                         
                                     }];
}



- (void)pickImages:(NSArray<UIImage *> *)images {
//    NSMutableArray<CTMSGImageMessage *>* imageMessages = [NSMutableArray array];
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTMSGImageMessage * imageMessage = [CTMSGImageMessage messageWithImage:obj];
        [[CTMSGIM sharedCTMSGIM] sendMediaMessage:ConversationType_PRIVATE
                                         targetId:_targetId
                                          content:imageMessage
                                      pushContent:nil
                                         pushData:nil
                                         progress:^(int progress, long messageId) {
                                             
                                         } success:^(long messageId) {
                                             
                                         } error:^(CTMSGErrorCode errorCode, long messageId) {
                                             
                                         } cancel:^(long messageId) {
                                             
                                         }];
//        [imageMessages addObject:imageMessage];
    }];
//    [imageMessages]
    
}

- (void)imageDidCapture:(UIImage *)image {
    CTMSGImageMessage * message = [[CTMSGImageMessage alloc] init];
    [self sendMediaMessage:message pushContent:nil appUpload:YES];
//    [[CTMSGIM sharedCTMSGIM] sendMediaMessage:_conversationType
//                                     targetId:_targetId
//                                      content:message
//                                  pushContent:nil
//                                     pushData:nil
//                                     progress:^(int progress, long messageId) {
//                                         if (_enableSaveNewPhotoToLocalSystem) {
//                                             [self saveNewPhotoToLocalSystemAfterSendingSuccess:image];
//                                         }
//                                     } success:^(long messageId) {
//
//                                     } error:^(CTMSGErrorCode errorCode, long messageId) {
//                                         
//                                     } cancel:^(long messageId) {
//
//                                     }];
}

- (void)sightDidFinishRecord:(NSString *)url thumbnail:(UIImage *)image duration:(NSUInteger)duration {
    CTMSGVideoMessage * message = [[CTMSGVideoMessage alloc] init];
    [self sendMediaMessage:message pushContent:nil appUpload:YES];
//    [[CTMSGIM sharedCTMSGIM] sendMediaMessage:_conversationType
//                                     targetId:_targetId
//                                      content:message
//                                  pushContent:nil
//                                     pushData:nil
//                                     progress:^(int progress, long messageId) {
//
//                                     } success:^(long messageId) {
//
//                                     } error:^(CTMSGErrorCode errorCode, long messageId) {
//
//                                     } cancel:^(long messageId) {
//
//                                     }];
}

- (void)chatSessionInputBarStatusChanged:(KBottomBarStatus)bottomBarStatus {
    //FIXME: - 可以考虑将bar的frame改变放入此方法中
}

#pragma mark - CTMSGChatCameraDelegate

- (void)ctmsg_cameraPhotoTaked:(CTMSGChatCameraViewController *)controller image:(UIImage *)image imagePath:(NSString *)imagePath {
    CTMSGImageMessage * imageMessage = [CTMSGImageMessage messageWithImage:image];
    [[CTMSGIM sharedCTMSGIM] sendMediaMessage:ConversationType_PRIVATE
                                     targetId:_targetId
                                      content:imageMessage
                                  pushContent:nil
                                     pushData:nil
                                     progress:^(int progress, long messageId) {
                                         
                                     } success:^(long messageId) {
                                         
                                     } error:^(CTMSGErrorCode errorCode, long messageId) {
                                         
                                     } cancel:^(long messageId) {
                                         
                                     }];
}

- (void)ctmsg_cameraVideoTaked:(CTMSGChatCameraViewController *)controller videoPath:(NSString *)videoPath {
    
}

- (void)ctmsg_cancelCamera:(CTMSGChatCameraViewController *)controller {
    
}

#pragma mark - touch event


#pragma mark - notification

- (void)keyboardWillShow:(NSNotification *)notificaiton {
    NSDictionary *info = notificaiton.userInfo;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _chatSessionInputBarControl.keyboardHeight = kbSize.height - CTMSGIphoneXBottomH;
    [self.view setNeedsLayout];
//    NSLog(@"keyboard changed, keyboard width = %f, height = %f", kbSize.width,kbSize.height);
}

- (void)keyboardWillHide:(NSNotification *)notificaiton {
    _chatSessionInputBarControl.keyboardHeight = 0;
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
    }
}

#pragma mark - notification

- (void)startPlay:(NSNotification *)notification {
    
}

- (void)stopPlay:(NSNotification *)notification {
    CTMSGMessageModel * model = notification.object;
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


#pragma mark - public

- (void)scrollToBottomAnimated:(BOOL)animated {
    
}

- (void)sendMessage:(CTMSGMessageContent *)messageContent pushContent:(NSString *)pushContent {
    [self willSendMessage:messageContent];
    CTMSGMessage * message = [[CTMSGMessage alloc] init];
    [self willAppendAndDisplayMessage:message];
    [[CTMSGIM sharedCTMSGIM] sendMessage:_conversationType
                                targetId:_targetId
                                 content:messageContent
                             pushContent:pushContent
                                pushData:nil
                                 success:^(long messageId) {
                                     [self didSendMessage:messageId
                                                  content:messageContent];
                                 } error:^(CTMSGErrorCode nErrorCode, long messageId) {
                                     
                                 }];
}

- (void)sendMediaMessage:(CTMSGMessageContent *)messageContent pushContent:(NSString *)pushContent appUpload:(BOOL)appUpload {
//    CTMSGVideoMessage * videoMessage = [[CTMSGVideoMessage alloc] init];
    CTMSGMessage * message = [[CTMSGMessage alloc] init];
//                              WithType:<#(CTMSGConversationType)#>
//                                                       targetId:<#(nonnull NSString *)#>
//                                                      direction:<#(CTMSGMessageDirection)#>
//                                                      messageId:mesa
//                                                        content:messageContent];
    if (appUpload) {
        CTMSGUploadMediaStatusListener * listener = [[CTMSGUploadMediaStatusListener alloc] initWithMessage:message uploadProgress:^(int progress) {
            
        } uploadSuccess:^(CTMSGMessageContent * _Nonnull content) {
            
        } uploadError:^(CTMSGErrorCode errorCode) {
            
        } uploadCancel:^{
            
        }];
        [self uploadMedia:message uploadListener:listener];
    }
}

- (void)uploadMedia:(CTMSGMessage *)message uploadListener:(CTMSGUploadMediaStatusListener *)uploadListener {
    //TODO: - use self upload not CTMSGIM OR CTMSGIMClient
//    [[CTMSGIM sharedCTMSGIM] sendMediaMessage:_conversationType
//                                     targetId:_targetId
//                                      content:message.content
//                                  pushContent:nil
//                                     pushData:nil
//                                     progress:^(int progress, long messageId) {
//                                         if (uploadListener.updateBlock) {
//                                             uploadListener.updateBlock(progress);
//                                         }
//                                     } success:^(long messageId) {
//                                         if (uploadListener.successBlock) {
//                                             uploadListener.successBlock(message.content);
//                                         }
//                                     } error:^(CTMSGErrorCode errorCode, long messageId) {
//                                         if (uploadListener.errorBlock) {
//                                             uploadListener.errorBlock(errorCode);
//                                         }
//                                     } cancel:^(long messageId) {
//                                         if (uploadListener.cancelBlock) {
//                                             uploadListener.cancelBlock();
//                                         }
//                                     }];
}

- (void)cancelUploadMedia:(CTMSGMessageModel *)model {
    
}

- (void)resendMessage:(CTMSGMessageContent *)messageContent {
    
}

- (void)appendAndDisplayMessage:(CTMSGMessage *)message {
    if (message) {
        LOCK
        NSInteger count = _conversationDataRepository.count;
        CTMSGMessageModel *model = [[CTMSGMessageModel alloc] initWithMessage:message];
        [_conversationDataRepository addObject:model];
        UNLOCK
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:count inSection:0];
            [_conversationMessageCollectionView insertItemsAtIndexPaths:@[indexPath]];
            if (_conversationMessageCollectionView.contentOffset.y >= _conversationMessageCollectionView.contentSize.height - _conversationMessageCollectionView.bounds.size.height) {
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
    return message;
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
    
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(CTMSGMessageModel *)model {
    return nil;
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

#pragma mark - lazy

//- (CTMSGEmojiBoardView *)board {
//    return <#expression#>;
//}

#pragma mark - init

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
    return self;
}

#pragma mark - private

- (void)p_ctmsg_figureOutShowDisplayTime {
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        CTMSGMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
        } else if (i > 0) {
            CTMSGMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
            long long previous_time = pre_model.sentTime;
            long long current_time = model.sentTime;
            
            long long interval =
            current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            if (interval / 1000 <= 3 * 60) {
                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height - 45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = NO;
            }
            else {
                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height + 45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = YES;
            }
        }
//        if ([[[model.content class] getObjectName] isEqualToString:@"RC:OldMsgNtf"]) {
//            model.isDisplayMessageTime = NO;
//        }
    }
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
