//
//  INTCTConversationViewController.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationViewController.h"
#import "INTCTFastTextView.h"
#import "INTCTLockMessageCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import <SDWebImageDownloader.h>
#import "INTCTAliOSS.h"
#import "UIView+INTCT_Frame.h"
#import "UIFont+INTCT_Custom.h"
#import "UIColor+INTCT_App.h"
#import "Header.h"

@interface INTCTConversationViewController (){
    NSInteger _reverseEndIndex;
    UIImage *_targetAvatarImage;
    UIImage *_avatarImage;
}

@property (nonatomic, strong) UIButton * fastTextBtn;
@property (nonatomic, strong) UIButton * favorBtn;

@property (nonatomic, strong) id<INTCTConversationDataSource> dataSource;
@property(nonatomic, strong) UIView *headNoteView;
@property(nonatomic, strong) INTCTFastTextView *fastTextView;
@property(nonatomic, strong) UIButton *inputBarLockBtn;
//@property(nonatomic, strong) UIView *inputBarLockView;
//@property (nonatomic, strong) LOTAnimationView * flowerView;

@property (nonatomic, strong) NSMutableArray<CTMSGMessage *> * latestDBMessages;
@property (nonatomic, copy) void(^netMessageBlock)(NSArray<CTMSGMessage *> * messages);

@end

@implementation INTCTConversationViewController

- (instancetype)initWithDataSource:(id<INTCTConversationDataSource>)dataSource {
    self = [super init];
    if (!self) return nil;
    _dataSource = dataSource;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationDidEnterBackgroundNotification object:nil];
    _reverseEndIndex = 0;
    [self p_intct_setNavView];
    [self p_intct_setView];
    [self p_intct_setDataSource];
    self.chatSessionInputBarControl.currentBottomBarStatus = self.chatSessionInputBarControl.currentBottomBarStatus;
    
//    CTMSGTextMessage * textMessage = [CTMSGTextMessage messageWithContent:@"ssss"];
//    [self sendMessage:textMessage pushContent:nil];
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    _fastTextBtn.frame = CGRectMake(self.view.width - 32 - 14, self.view.height - 32 - 94, 32, 32);
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_dataSource.conversationFrom == INTCTConversationMatch) {
        __weak typeof(self) weakSelf = self;
        [weakSelf.dataSource beginTimerWith:^{
            weakSelf.title = weakSelf.dataSource.countDonwTitle;
            if (weakSelf.dataSource.countDonwTime == 60) {
                weakSelf.favorBtn.hidden = NO;
            }
            else if (weakSelf.dataSource.countDonwTime == 0) {
                [weakSelf p_timedown];
            }
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_dataSource readAllMessage];
    [[CTMSGDataBaseManager shareInstance] removeAllMatchChatMessagesWithTargetUserId:self.targetId];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - set view

- (void)p_intct_setNavView {
//    [self intct_setNavView];
//    self.navBarTintColor = [UIColor navColor];
//    self.navBarBgAlpha = 1;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStylePlain target:self action:@selector(p_ctmsg_clickMore:)];
//    [self.navigationItem.rightBarButtonItem intct_titleColor:[UIColor blackTextColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowleft_24_black_2_round"] style:UIBarButtonItemStylePlain target:self action:@selector(p_intct_close)];
    if (self.conversationFrom == INTCTConversationMatch) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)p_intct_setView {
    _fastTextBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(p_intct_showFastText:) forControlEvents:UIControlEventTouchUpInside];
        
//        [INTCTViewHelper intct_buttonWithFrame:CGRectMake(self.view.width - 32 - 14, self.view.height - 32 - 94 - kIphoneXBottomHeight, 32, 32)
//                                                           bgImage:nil
//                                                             image:@"message_quickreply_plus"
//                                                             title:nil
//                                                         textColor:nil
//                                                            method:@selector(p_intct_showFastText:)
//                                                            target:self];
        [self.view addSubview:button];
        button;
    });
    if (_dataSource.conversationFrom == INTCTConversationNormal) {
//        [self.conversationMessageCollectionView registerClass:[INTCTLockMessageCell class] forCellWithReuseIdentifier:@"INTCTLockMessageCell"];
    } else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self.view addSubview:self.headNoteView];
        self.chatSessionInputBarControl.voiceButton.enabled = NO;
        self.chatSessionInputBarControl.albumButton.enabled = NO;
        self.chatSessionInputBarControl.cameraButton.enabled = NO;
    }
}

- (void)p_intct_setDataSource {
    __weak typeof(self) weakSelf = self;
    _avatarImage = [UIImage imageNamed:@"avatar"];
    _targetAvatarImage = [UIImage imageNamed:@"avatar"];
    [_dataSource setRefreshBlock:^(BOOL needRefresh) {
        if (needRefresh) {
            if (weakSelf.dataSource.needPlayFlower) {
//                [weakSelf.flowerView play];
            }
            weakSelf.chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
            [weakSelf p_set_cell_avatar];
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (weakSelf.dataSource.conversationFrom == INTCTConversationNormal) {
                weakSelf.title = weakSelf.dataSource.nickname;
                weakSelf.chatSessionInputBarControl.voiceButton.enabled = YES;
                weakSelf.chatSessionInputBarControl.albumButton.enabled = YES;
                weakSelf.chatSessionInputBarControl.cameraButton.enabled = YES;
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                [strongSelf->_headNoteView removeFromSuperview];
                strongSelf->_headNoteView = nil;
                if (strongSelf) {
                    strongSelf->_favorBtn.hidden = YES;
                }
            }
            else {
                if (weakSelf.dataSource.didFavored) {
                    if (weakSelf) {
                        weakSelf.favorBtn.selected = YES;
                    }
                }
                UILabel * label = weakSelf.headNoteView.subviews.firstObject;
                label.text = weakSelf.dataSource.matchTopNote;
            }
            [weakSelf p_intct_netMessageCallback];
        }
    }];
}

- (void)p_set_cell_avatar {
    if (!_avatarImage || _targetAvatarImage) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:_dataSource.selfAvatarURL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
//                _avatarImage = [UIImage image:image byScalingToSize:CGSizeMake(40, 40)];
            }
        }];
        if (_dataSource.conversationFrom == INTCTConversationNormal) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:_dataSource.avatarURL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
//                    _targetAvatarImage = [UIImage image:image byScalingToSize:CGSizeMake(40, 40)];
                    [self.conversationMessageCollectionView reloadData];
                }
            }];
        }
        else {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:_dataSource.avatarURL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
//                    _targetAvatarImage = [[UIImage image:image byScalingToSize:CGSizeMake(40, 40)] addGaussinBlur:0.5];
                    [self.conversationMessageCollectionView reloadData];
                }
            }];
        }
    }
}

- (void)didTapMessageCell:(CTMSGMessageModel *)model {
//    if (model.messageDirection == CTMSGMessageDirectionReceive) {
////        if (_dataSource.messageLock) {
////            [self p_intct_inputUnlock:nil];
////            //            [INTCTOpenPageHelper intct_showCustomAlertWithTitle:@"是否解锁？" block:^(INTCTOpenAlert * _Nonnull alert) {
////            //                alert.title(INTCTAlertCancelTitle).cancelStyle();
////            //                alert.title(INTCTAlertSureTitle).destructiveStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
////            //                    [_dataSource unlockMessage];
////            //                };
////            //            }];
////            return ;
////        }
//    } else {
//        if (model.sentStatus == SentStatus_FAILED) {
//            [INTCTOpenPageHelper intct_showCustomAlertWithTitle:@"是否重新发送？" block:^(INTCTOpenAlert * _Nonnull alert) {
//                alert.canceltitle().cancelStyle();
//                alert.sureTitle().destructiveStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//                    [self resendMessage:model];
//                };
//            }];
//            return;
//        }
//    }
//    CTMSGMessageContent * content = model.content;
//    if ([content isKindOfClass:CTMSGImageMessage.class] ||
//        [content isKindOfClass:CTMSGVideoMessage.class]) {
//        __block UIImageView * fromView;
//        [self.conversationMessageCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (((CTMSGMessageBaseCell *)obj).model == model) {
//                if ([obj isKindOfClass:CTMSGImageMessageCell.class]) {
//                    fromView = ((CTMSGImageMessageCell *)obj).pictureView;
//                } else if ([obj isKindOfClass:CTMSGVideoMessageCell.class]) {
//                    fromView = ((CTMSGVideoMessageCell *)obj).pictureView;
//                }
//                *stop = YES;
//            }
//        }];
//
//        NSMutableArray * photoItems = [NSMutableArray array];
//        [self.conversationDataRepository enumerateObjectsUsingBlock:^(CTMSGMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            __block UIImageView * imageView;
//            if ([obj.content isKindOfClass:CTMSGImageMessage.class] ||
//                [obj.content isKindOfClass:CTMSGVideoMessage.class]) {
//                [self.conversationMessageCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull tempCell, NSUInteger idx, BOOL * _Nonnull cellStop) {
//                    if (((CTMSGMessageBaseCell *)tempCell).model == obj) {
//                        if ([tempCell isKindOfClass:CTMSGImageMessageCell.class]) {
//                            imageView = ((CTMSGImageMessageCell *)tempCell).pictureView;
//                        } else if ([tempCell isKindOfClass:CTMSGVideoMessageCell.class]) {
//                            imageView = ((CTMSGVideoMessageCell *)tempCell).pictureView;
//                        }
//                        *cellStop = YES;
//                    }
//                }];
//                if ([obj.content isKindOfClass:CTMSGImageMessage.class]) {
//                    NSString * url = ((CTMSGImageMessage *)obj.content).imageURL;
//                    YYPhotoGroupItem *item = [YYPhotoGroupItem new];
//                    INTCTAlbum * album = [[INTCTAlbum alloc] init];
//                    album.type = 1;
//                    album.link = url;
//                    item.largeImageURL = [NSURL URLWithString:url];
//                    if (!imageView) {
//                        imageView = [UIImageView new];
//                    }
//                    album.isVideo = NO;
//                    item.thumbView = imageView;
//                    item.album = album;
//                    [photoItems addObject:item];
//                } else if ([obj.content isKindOfClass:CTMSGVideoMessage.class]) {
//                    NSString * url = ((CTMSGVideoMessage *)obj.content).localaPath;
//                    if (!url) {
//                        url = ((CTMSGVideoMessage *)obj.content).videoURL;
//                    }
//                    YYPhotoGroupItem *item = [YYPhotoGroupItem new];
//                    INTCTAlbum * album = [[INTCTAlbum alloc] init];
//                    album.type = 1;
//                    album.link = url;
//                    item.largeImageURL = [NSURL URLWithString:url];
//                    album.isVideo = YES;
//                    if (!imageView) {
//                        imageView = [UIImageView new];
//                    }
//                    item.thumbView = imageView;
//                    item.album = album;
//                    [photoItems addObject:item];
//                }
//            }
//        }];
//        YYPhotoBrowseView *groupView = [[YYPhotoBrowseView alloc]initWithGroupItems:photoItems];
//        groupView.showEdit = NO;
//        groupView.blurEffectBackground = NO;
//
//        [groupView intct_presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
//    }
}

- (void)didTapCellPortrait:(NSString *)userId {
    if ([userId isEqualToString:_dataSource.uid]) {
//        [INTCTOpenPageHelper openMyHomeWithUserid:userId];
    }
    else {
        if (_dataSource.conversationFrom == INTCTConversationMatch) {
            
        } else {
//            [INTCTOpenPageHelper openMyHomeWithUserid:userId];
        }
    }
}

- (void)deleteMessage:(CTMSGMessageModel *)model {
    [_dataSource deleteMessage:model resultBlock:^(NSError *error) {
        if (!error) {
            [self.conversationDataRepository enumerateObjectsUsingBlock:^(CTMSGMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj == model) {
                    [self.conversationDataRepository removeObject:obj];
                    [self.conversationMessageCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                    *stop = YES;
                }
            }];
        }
    }];
}

#pragma mark - touch event

//- (void)p_intct_back:(UIButton *)sender {
//
//}

- (void)p_intct_close {
    switch (_dataSource.conversationFrom) {
        case INTCTConversationMatch: {
//            [INTCTOpenPageHelper intct_showCustomAlertWithTitle:@"是否退出180秒心动时刻？" message:@"退出后将再也无法返回到这个聊天" alertStyle:UIAlertControllerStyleAlert block:^(INTCTOpenAlert * _Nonnull alert) {
//                alert.title(@"退出").cancelStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//                    [self intct_close];
//                    [self.dataSource leaveMatch];
//                };
//                alert.title(@"留下").defaultStyle();
//            }];
        }
            break;
        case INTCTConversationNormal:
//            [self intct_close];
            break;
    }
}

- (void)p_fastTextClick:(UIButton *)sender {
    NSUInteger index = sender.tag - 10;
//    NSString * title = [_dataSource.quickTexts objectOrNilAtIndex:index];
    NSString * title = @"sdsd";
    [self p_closeFastTextView];
    CTMSGTextMessage * textMessage = [CTMSGTextMessage messageWithContent:title];
    [self sendMessage:textMessage pushContent:nil];
//    self.chatSessionInputBarControl.inputTextView.text = title;
//    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
//    self.chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarKeyboardStatus;
}

- (void)p_intct_showFastText:(UIBarButtonItem *)sender {
    [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
    self.chatSessionInputBarControl.currentBottomBarStatus = CTMSGBottomInputBarDefaultStatus;
    [self.navigationController.view addSubview:self.fastTextView];
    _fastTextBtn.hidden = YES;
//    [_dataSource clickMore];
}

- (void)p_intct_favor:(UIButton *)sender {
    [_dataSource clickFavor];
}

- (void)p_ctmsg_clickMore:(UIBarButtonItem *)sender {
    [_dataSource clickMore];
}

- (void)p_ctmsg_clickAvatar:(UIBarButtonItem *)sender {
    [_dataSource clickNavAvatar];
}

- (void)p_intct_inputUnlock:(UIButton *)sender {
//    [INTCTOpenPageHelper intct_showCustomAlertWithTitle:_dataSource.unlockAlert block:^(INTCTOpenAlert * _Nonnull alert) {
//        alert.title(INTCTAlertCancelTitle).cancelStyle();
//        alert.title(INTCTAlertSureTitle).destructiveStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//            [_dataSource unlockMessage];
//        };
//    }];
}

- (void)p_closeFastTextView {
    [self.fastTextView removeFromSuperview];
    _fastTextBtn.hidden = NO;
}

#pragma mark - notification

- (void)resignActive {
    [_dataSource readAllMessage];
}

#pragma mark - public

//- (CTMSGMessage *)willAppendAndDisplayMessage:(CTMSGMessage *)message {
//    if (message.messageDirection == CTMSGMessageDirectionReceive) {
//        [_dataSource readReceiveMessage:message.messageUId];
//    }
//    return [super willAppendAndDisplayMessage:message];
//}

- (void)ctmsg_resetFrame:(CGRect)barFrame {
    self.chatSessionInputBarControl.frame = barFrame;
    CGFloat chatSessionTop = barFrame.origin.y;
    CGFloat headerHeight = INTCTNavBarHeight;
    if (self.chatSessionInputBarControl.currentBottomBarStatus != CTMSGBottomInputBarDefaultStatus &&
        self.chatSessionInputBarControl.currentBottomBarStatus != CTMSGBottomInputBarLockStatus) {
    }
    if (_dataSource.conversationFrom == INTCTConversationMatch) {
        _headNoteView.frame = (CGRect){0, headerHeight, self.view.width, 32};
        headerHeight += 32;
    }
    CGFloat collectHeight = self.view.height - kIphoneXBottomHeight - CTMSGInputNormalHeight - headerHeight;
    CGFloat collectTop = chatSessionTop - collectHeight;
    self.conversationMessageCollectionView.frame = (CGRect){0, collectTop, self.view.width, collectHeight};
    _fastTextBtn.frame = CGRectMake(self.view.width - 32 - 14, barFrame.origin.y - 32 - 20, 32, 32);
    [self.chatSessionInputBarControl setNeedsLayout];
}

- (void)ctmsg_fetchMessages {
//    if (_dataSource.conversationFrom == INTCTConversationMatch) return;
    [super ctmsg_fetchMessages];
}

- (void)ctmsg_fetchDBMessage {
    if (_dataSource.conversationFrom == INTCTConversationMatch) return;
    [super ctmsg_fetchDBMessage];
}

- (void)ctmsg_fetchNetMessage:(void (^)(NSArray<CTMSGMessage *> * _Nullable))resultBlock {
    _netMessageBlock = resultBlock;
    if (_dataSource.conversationFrom == INTCTConversationMatch) {
        [_dataSource intct_fetchFirstPageData];
        return;
    }
    if (_dataSource.currentPage < 0) {
        [_dataSource intct_fetchFirstPageData];
    } else {
        [_dataSource intct_fetchNextPageData];
    }
}

- (BOOL)didShowAllAfterLoadNextPageMessage {
    return _dataSource.hasMore;
}

//- (NSString *)customCellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CTMSGMessageModel * message = self.conversationDataRepository[indexPath.row];
//    if (message.messageDirection == CTMSGMessageDirectionReceive) {
//        if (_dataSource.messageLock) {
//            return @"INTCTLockMessageCell";
//        }
//    }
//    return nil;
//}

- (void)willDisplayMessageCell:(CTMSGMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CTMSGMessageCell class]]) {
        CTMSGMessageCell * messageCell = (CTMSGMessageCell *)cell;
        if (cell.model.messageDirection == CTMSGMessageDirectionReceive) {
            [messageCell.portraitBtn setImage:_targetAvatarImage forState:UIControlStateNormal];
        }
        else {
            [messageCell.portraitBtn setImage:_avatarImage forState:UIControlStateNormal];
        }
    }
}

//- (CTMSGMessageModel *)customMessageoModelForItemAtIndexPath:(NSIndexPath *)indexPath {
//    static CTMSGMessageModel * model;
//    if (!model) {
//        CTMSGTextMessage * lock = [CTMSGTextMessage messageWithContent:_dataSource.messageLockText];
//        CTMSGMessage * message = [[CTMSGMessage alloc] initWithType:ConversationType_PRIVATE targetId:self.targetId direction:CTMSGMessageDirectionReceive messageId:LONG_MAX content:lock];
//        model = [CTMSGMessageModel modelWithMessage:message];
//    }
//    return model;
//}

//- (CGSize)customCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    static CGSize size;
//    if (CGSizeEqualToSize(size, CGSizeZero)) {
//        CTMSGTextMessage * lock = [CTMSGTextMessage messageWithContent:_dataSource.messageLockText];
//        CTMSGMessage * message = [[CTMSGMessage alloc] initWithType:ConversationType_PRIVATE targetId:self.targetId direction:CTMSGMessageDirectionReceive messageId:LONG_MAX content:lock];
//        CTMSGMessageModel * model = [CTMSGMessageModel modelWithMessage:message];
//        size = [INTCTLockMessageCell sizeForMessageModel:model withCollectionViewWidth:INTCTSCREENWIDTH referenceExtraHeight:20];
//    }
//    return size;
//}

- (CTMSGMessageContent *)willSendMessage:(CTMSGMessageContent *)messageContent {
    if (!messageContent.senderUserInfo) {
//        messageContent.senderUserInfo = [[CTMSGUserInfo alloc] initWithUserId:self.targetId name:_dataSource.nickname portrait:_dataSource.avatar isVip:_dataSource.isVip];
        messageContent.senderUserInfo = [[CTMSGUserInfo alloc] initWithUserId:self.targetId name:_dataSource.nickname portrait:_dataSource.avatar isVip:NO];
    }
    if (_dataSource.conversationFrom == INTCTConversationMatch) {
        messageContent.extraPara = @{@"chatType" : @"fastChat"};
    }
    return messageContent;
}

- (void)uploadMedia:(CTMSGMessage *)message uploadListener:(CTMSGUploadMediaStatusListener *)uploadListener {
    [super uploadMedia:message uploadListener:uploadListener];
    NSData * uploadData = nil;
    CTMSGMessageContent * content = message.content;
    NSDictionary * dic;
    if (_dataSource.conversationFrom == INTCTConversationMatch) {
        dic = @{@"chatType" : @"fastChat"};
    }
    
    if (![CTMSGNetManager netReachable]) {
        NSString * domain = @"com.banteaysrei.chatdetail.uploadmedia";
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey : @"当前无网络连接！"};
        NSError * error = [NSError errorWithDomain:domain code:-1011 userInfo:userInfo];
//        [INTCTHUDPopHelper showTextHUD:error.localizedDescription];
        if (uploadListener.errorBlock) {
            uploadListener.errorBlock(CTMSG_CHANNEL_INVALID);
        }
        return;
    }
    if ([content isKindOfClass:[CTMSGVoiceMessage class]]) {
        uploadData = ((CTMSGVoiceMessage *)content).wavAudioData;
        float duration = ((CTMSGVoiceMessage *)content).duration;
        INTCTAliOSS * aliOSS = [[INTCTAliOSS alloc] initWithNSDictionary:_dataSource.uploadConfig];
        [aliOSS uploadMessageWav:uploadData duration:duration parameters:dic progress:^(float progressValue) {
            if (uploadListener.updateBlock) {
                uploadListener.updateBlock(progressValue);
            }
        } result:^(NSError * _Nullable error, long messageUId, id  _Nullable result) {
            if (!error) {
                NSString * voiceURL = result[@"aliOSS"][@"data"][@"link"];
                NSDictionary * dic;
                if (voiceURL) {
                    dic = @{@"voiceURL" : voiceURL};
                }
                if (uploadListener.successBlock) {
                    uploadListener.successBlock(content, messageUId, dic);
                }
            }
            else {
//                [INTCTHUDPopHelper showTextHUD:error.localizedDescription];
                if (uploadListener.errorBlock) {
                    uploadListener.errorBlock(ERROCTMSGODE_UNKNOWN);
                }
            }
        }];
    }
    else if ([content isKindOfClass:[CTMSGImageMessage class]]) {
        UIImage * image = ((CTMSGImageMessage *)content).originalImage;
        INTCTAliOSS * aliOSS;
        //        = _multiImageAliOSS;
        //        if (!aliOSS) {
        aliOSS = [[INTCTAliOSS alloc] initWithNSDictionary:_dataSource.uploadConfig];
        //        }
        [aliOSS uploadMessageImage:image parameters:dic progress:^(float progressValue) {
            if (uploadListener.updateBlock) {
                uploadListener.updateBlock(progressValue);
            }
        } result:^(NSError * _Nullable error, long messageUId, id  _Nullable result) {
            if (!error) {
                NSString * imageURL = result[@"aliOSS"][@"data"][@"link"];
                NSString * thumbURL = result[@"aliOSS"][@"data"][@"thumblink"];
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                if (imageURL) {
                    [dic setValue:imageURL forKey:@"imageURL"];
                }
                if (thumbURL) {
                    [dic setValue:thumbURL forKey:@"thumbURL"];
                }
                if (uploadListener.successBlock) {
                    uploadListener.successBlock(content, messageUId, dic);
                }
            }
            else {
//                [INTCTHUDPopHelper showTextHUD:error.localizedDescription];
                if (uploadListener.errorBlock) {
                    uploadListener.errorBlock(ERROCTMSGODE_UNKNOWN);
                }
            }
        }];
    }
    else if ([content isKindOfClass:[CTMSGVideoMessage class]]) {
        NSString * path = ((CTMSGVideoMessage *)content).localaPath;
        INTCTAliOSS * aliOSS = [[INTCTAliOSS alloc] initWithNSDictionary:_dataSource.uploadConfig];
        UIImage * image = ((CTMSGVideoMessage *)content).thumbnailImage;
        [aliOSS uploadMessageVideo:path videoSize:image.size parameters:dic progress:^(float progressValue) {
            if (uploadListener.updateBlock) {
                uploadListener.updateBlock(progressValue);
            }
        } result:^(NSError * _Nullable error, long messageUId, id  _Nullable result) {
            if (!error) {
                NSString * videoURL = result[@"aliOSS"][@"data"][@"link"];
                NSDictionary * dic;
                if (videoURL) {
                    dic = @{@"videoURL" : videoURL};
                }
                if (uploadListener.successBlock) {
                    uploadListener.successBlock(content, messageUId, dic);
                }
            }
            else {
//                [INTCTHUDPopHelper showTextHUD:error.localizedDescription];
                if (uploadListener.errorBlock) {
                    uploadListener.errorBlock(ERROCTMSGODE_UNKNOWN);
                }
            }
        }];
    }
}

- (void)p_intct_netMessageCallback {
    if (_netMessageBlock) {
        if (_dataSource.serverMessages) {
            _netMessageBlock(_dataSource.serverMessages);
        }
    }
}

#pragma mark - self public

- (void)receiveMatchFavor {
    [_dataSource receiveMatchFavor];
}

- (void)receiveMatchOut {
    [self.navigationController.view showTextHUD:@"对方已退出匹配!"];
    [_dataSource receiveMatchOut];
}

- (INTCTConversationFrom)conversationFrom {
    return _dataSource.conversationFrom;
}

#pragma mark - private

- (void)p_timedown {
    [_dataSource leaveMatch];
//    [INTCTOpenPageHelper intct_showCustomAlertWithTitle:@"限时聊天结束，即将退出！" message:nil alertStyle:UIAlertControllerStyleAlert block:^(INTCTOpenAlert * _Nonnull alert) {
//        alert.sureTitle().defaultStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//            [self intct_close];
//        };
////        alert.title(@"留下").defaultStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
////            [self.dataSource cancelTimer];
////        };
//    }];
}

#pragma mark - lazy

- (UIView *)headNoteView {
    if (!_headNoteView) {
        _headNoteView = [[UIView alloc] initWithFrame:CGRectMake(0, INTCTNavBarHeight, self.view.width, 32)];
        UILabel * label = ({
            UILabel * label = [[UILabel alloc] init];
            
//            [INTCTViewHelper intct_labelWithFrame:CGRectZero
//                                                              title:@"Tips:你们只有180s的聊天时间，要珍惜TA哦~"
//                                                               font:[UIFont intct_PingFangMedium12]
//                                                          textColor:[UIColor whiteColor]];
            [label sizeToFit];
            [self.view addSubview:label];
            label;
        });
        _headNoteView.backgroundColor = [UIColor color_ff9191];
        label.centerY = _headNoteView.height / 2;
        label.left = 10;
        [_headNoteView addSubview:label];
    }
    return _headNoteView;
}

//- (UIView *)inputBarLockView {
//    if (!_inputBarLockView) {
//        _inputBarLockView = ({
//            UIView * view = [[UIView alloc] init];
//            view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
//            //            view.backgroundColor = [UIColor clearColor];
//            view;
//        });
//    }
//
//    _inputBarLockBtn = ({
//        UIButton * button = [INTCTViewHelper intct_buttonWithFrame:CGRectZero
//                                                           bgImage:nil
//                                                             image:@""
//                                                             title:nil
//                                                         textColor:[UIColor whiteColor]
//                                                            method:@selector(p_intct_inputUnlock:)
//                                                            target:self];
//        button.titleLabel.lineBreakMode = 0;
//        button.titleLabel.font = [UIFont intct_PingFangMedium16];
//        button.backgroundColor = [UIColor clearColor];
//        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        [_inputBarLockView addSubview:button];
//        button;
//    });
//    return _inputBarLockView;
//}

- (UIButton *)favorBtn {
    if (!_favorBtn) {
        _favorBtn = ({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(self.view.width - 14 - 144, 56 + INTCTNavBarHeight, 144, 40);
            [button addTarget:self action:@selector(p_intct_favor:) forControlEvents:UIControlEventTouchUpInside];
            
//            [INTCTViewHelper intct_buttonWithFrame:CGRectMake(self.view.width - 14 - 144, 56 + INTCTNavBarHeight, 144, 40)
//                                                               bgImage:nil
//                                                                 image:@"match_like_act"
//                                                                 title:nil
//                                                             textColor:nil
//                                                                method:@selector(p_intct_favor:)
//                                                                target:self];
            [button setImage:[UIImage imageNamed:@"match_like_def"] forState:UIControlStateSelected];
            [self.view addSubview:button];
            button;
        });
    }
    return _favorBtn;
}

- (INTCTFastTextView *)fastTextView {
    if (!_fastTextView) {
        _fastTextView = [[INTCTFastTextView alloc] initWithTexts:_dataSource.quickTexts];
        [_fastTextView.closeBtn addTarget:self action:@selector(p_closeFastTextView) forControlEvents:UIControlEventTouchUpInside];
        [_fastTextView.textBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj addTarget:self action:@selector(p_fastTextClick:) forControlEvents:UIControlEventTouchUpInside];
        }];
//                         initWithFrame:self.navigationController.view.bounds];
        _fastTextView.frame = self.navigationController.view.bounds;
    }
    return _fastTextView;
}

//- (LOTAnimationView *)flowerView {
//    if (!_flowerView) {
//        _flowerView = [LOTAnimationView animationNamed:@"favor-flower"];
//        _flowerView.frame = (CGRect){(self.view.width - 200) / 2, (self.view.height - 200) / 2, 200, 200};
//        [self.view addSubview:_flowerView];
//    }
//    return _flowerView;
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
