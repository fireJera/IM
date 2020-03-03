//
//  INTCTConversationViewmodel.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationViewmodel.h"
#import "INTCTConversationModel.h"
#import "INTCTConversationListViewmodel.h"
#import <MMessageKit/MMessageKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "INTCTNetWorkManager+IChat.h"
#import "INTCTUser.h"

@interface INTCTConversationViewmodel () {
    //    BOOL _isRefresh;
    int _countDown;
    BOOL _receiveMathFavor;
    NSTimeInterval _terminal;
}

@property (nonatomic, strong) INTCTConversationModel * model;
@property (nonatomic, copy) NSString * targetId;
@property (nonatomic, strong) NSMutableArray<CTMSGMessage *> * serverMessage;
@property (nonatomic, assign) INTCTConversationFrom type;
//@property (nonatomic, strong) INTCTGCDTimer * timer;
//@property (nonatomic, copy) INTCTVoidBlock timerBlock;

@end
@implementation INTCTConversationViewmodel

- (id)initWithConverstaionFrom:(INTCTConversationFrom)conversationFrom targetId:(NSString *)targetId {
    self = [super init];
    if (!self) return nil;
    _targetId = targetId;
    _type = conversationFrom;
    _currentPage = -1;
    _receiveMathFavor = NO;
    return self;
}

- (id)initWithTargetId:(NSString *)targetId {
    return [self initWithConverstaionFrom:INTCTConversationNormal targetId:targetId];
}

- (void)intct_fetchData {
    //    _isRefresh = YES;
    MBProgressHUD * hud;
    if (_currentPage == 0) {
//        hud = [INTCTHUDPopHelper customProgressHUDTitle:@""];
    }
    BOOL isMatch = _type == INTCTConversationMatch;
    [INTCTNetWorkManager intct_chatDetailWithTargetId:_targetId lastId:_model.lastId isMatch:isMatch result:^(NSError * _Nullable error, INTCTConversationModel * _Nullable chatDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        if (!error) {
            if (_type == INTCTConversationNormal) {
                NSArray * insertArray = chatDetail.messages;
                NSMutableArray<CTMSGMessage *> * arr = [NSMutableArray array];
                [insertArray enumerateObjectsUsingBlock:^(INTCTChatDetailMsg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CTMSGMessage * message = [obj copy];
                    [arr addObject:message];
                }];
                _serverMessage = arr;
            }
            else {
//                chatDetail.hasMore = NO;
//                chatDetail.isLock = NO;
            }
            if (_currentPage == 0) {
                _model = chatDetail;
//                CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:_targetId name:_model.user.nickname portrait:_model.user.avatar isVip:_model.user.isVip];
                CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:_targetId name:_model.user.nickname portrait:_model.user.avatar isVip:NO];
                [[CTMSGIM sharedCTMSGIM] refreshUserInfoCache:user];
            } else {
                _model.hasMore = chatDetail.hasMore;
                _model.lastId = chatDetail.lastId;
            }
            [INTCTInstanceChatList_VM readMessageWithTargetId:_targetId];
        }
        if (_refreshBlock) {
            _refreshBlock(chatDetail != nil);
        }
        //        _isRefresh = NO;
    }];
}

- (void)deleteMessage:(CTMSGMessageModel *)model resultBlock:(void (^)(NSError *))resultBlock {
    [INTCTNetWorkManager deleteMessageWithTargetId:_targetId msgUid:model.messageUId result:^(NSError * _Nullable error) {
        if (!error) {
            [[CTMSGDataBaseManager shareInstance] removeMessagewithUid:model.messageUId];
        }
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

- (INTCTConversationFrom)conversationFrom {
    return _type;
}

- (NSDictionary *)uploadConfig {
    return _model.ossConfig;
}

- (NSString *)messageLockText {
    return @"点击查看他发来的消息";
}

- (NSString *)nickname {
    if (!_model.user.nickname) {
        return nil;
    }
    return [NSString stringWithFormat:@" %@", _model.user.nickname];
}

//- (NSString *)inputLockNote {
//    return _model.bottomLockNote;
//}
//
//- (NSString *)unlockAlert {
//    return _model.lockAlertText;
//}

- (NSURL *)avatarURL {
    return [NSURL URLWithString:_model.user.avatar];
}

- (NSURL *)selfAvatarURL {
    return [NSURL URLWithString:INTCTINSTANCE_USER.avatar];
}

- (NSString *)avatar {
    return _model.user.avatar;
}

//- (BOOL)isVip {
//    return _model.user.isVip;
//}

- (BOOL)showWechat {
    return _model.user.hasWechat;
}

- (BOOL)hasMore {
    return _model.hasMore;
}

//- (BOOL)messageLock {
//    if (!_model) return YES;
//    return _model.isLock;
//}

//- (BOOL)isRefreshing {
//    return _isRefresh;
//}

- (NSUInteger)countDonwTime {
    return _countDown;
}

- (NSString *)countDonwTitle {
    return [NSString stringWithFormat:@"%ds", _countDown];
}

- (NSArray<NSString *> *)quickTexts {
    return _model.quickTexts;
}

- (NSMutableArray<CTMSGMessage *> *)serverMessages {
    return _serverMessage;
}

- (NSString *)matchTopNote {
    return _model.matchNote;
}

- (BOOL)didFavored {
    return _model.favored;
}

- (BOOL)needPlayFlower {
    return _receiveMathFavor && _model.favored;
}

//- (void)unlockMessage {
//    [INTCTNetWorkManager intct_msgUnlock:self.targetId result:^(NSError * _Nullable error, NSDictionary * _Nullable resultDic) {
//        if (!error) {
//            _model.isLock = NO;
//            [[NSNotificationCenter defaultCenter] postNotificationName:INTCTChatListUserUnlockNotification object:nil userInfo:@{@"userid": _targetId}];
//        }
//        if (_refreshBlock) {
//            _refreshBlock(error == nil);
//        }
//    }];
//}

//- (void)beginTimerWith:(INTCTVoidBlock)timerBlock {
//    if (!_timer) {
//        _countDown = 180;
//        _terminal = [[NSDate date] timeIntervalSince1970];
//        _timerBlock = timerBlock;
//        __weak typeof(self) weakSelf = self;
//        _timer = [INTCTGCDTimer scheduledDispatchTimerTimeInterval:1 repeats:YES callBlockNow:YES action:^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            if (weakSelf) {
//                strongSelf->_countDown--;
//                if (strongSelf->_countDown <= 0) {
//                    [self leaveMatch];
//                    [weakSelf.timer cancelDispatchTimer];
//                    weakSelf.timer = nil;
//                }
//                if (weakSelf.timerBlock) {
//                    weakSelf.timerBlock();
//                }
//            }
//        }];
//    }
//}

- (void)leaveMatch {
//    [_timer cancelDispatchTimer];
//    _timer = nil;
//    [[CTMSGDataBaseManager shareInstance] removeAllMatchChatMessagesWithTargetUserId:_targetId];
//    if (_type == INTCTConversationMatch) {
////        [[CTMSGIMClient sharedCTMSGIMClient] removeConversation:ConversationType_PRIVATE targetId:_targetId];
////        [[NSNotificationCenter defaultCenter] postNotificationName:INTCTMatchLeaveNotification object:nil];
//    }
//    [INTCTNetWorkManager intct_exitMatchConversationWithUserId:_targetId result:^(NSError * _Nullable error) {
//        
//    }];
}

- (void)readAllMessage {
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
    int interval = MAX(0, 180 - (nowInterval - _terminal));
    _countDown = interval;
    
    [INTCTNetWorkManager readMessageInChatDetail:_targetId result:^(NSError * _Nullable error) {
        
    }];
}

- (void)clickMore {
//    [[INTCTNetCallback alloc] init].intct_deal(_model.reportRequest);
//    NSString * str = _model.user.isBlack ? @"取消拉黑" : @"拉黑";
//    INTCTBottomSheet *sheet = [INTCTBottomSheet intct_bottomSheetWithTitleArray:@[str, @"举报"] block:^(NSInteger index) {
//        if (index == 0) {
//            [INTCTNetWorkManager intct_blackWithUserId:self.targetId result:^(NSError * _Nonnull error, NSDictionary * _Nullable result) {
//                if (!error) {
//                    BOOL isBlack = [result[@"afterStatus"] intValue];
//                    _model.user.isBlack = isBlack;
//                    NSString * hudString = _model.user.isBlack ? @"拉黑成功" : @"取消拉黑成功";
//                    [INTCTHUDPopHelper showTextHUD:hudString];
//                }
//            }];
//        }
//        else if (index == 1) {
//            [[INTCTNetCallback alloc] init].intct_deal(_model.reportRequest);
//        }
//    }];
//    [sheet intct_show];
}

- (void)clickFavor {
    [INTCTNetWorkManager intct_matchFollow:_targetId result:^(NSError * _Nullable error, BOOL followed) {
        if (!error) {
            _model.favored = YES;
            if (!_receiveMathFavor) {
                if (_refreshBlock) {
                    _refreshBlock(YES);
                }
            }
            else {
                [self p_recheck_match];
            }
        }
    }];
}

- (void)clickNavAvatar {
    [self clickHeaderAvatar];
}

- (void)receiveMatchFavor {
    _receiveMathFavor = YES;
    [self p_recheck_match];
}

- (void)receiveMatchOut {
//    [INTCTOpenPageHelper intct_close];
    [self leaveMatch];
}

- (void)p_recheck_match {
    if (_receiveMathFavor == YES &&
        _model.favored) {
        _type = INTCTConversationNormal;
//        [_timer cancelDispatchTimer];
//        _timer = nil;
//        _timerBlock = nil;
        if (_refreshBlock) {
            _refreshBlock(YES);
        }
    }
}

#pragma mark - INTCTChatDeatilHeaderSource

//- (NSInteger)headerPhotoCount {
//    return _model.albums.count + 1;
//}
//
//- (NSURL *)headerImageURLForIndex:(NSInteger)index {
//    INTCTAlbum * album = [_model.albums objectOrNilAtIndex:index];
//    if (!album) return nil;
//    return [NSURL URLWithString:album.linkThumb];
//}
//
//- (BOOL)showPlayIconForIndex:(NSInteger)index {
//    INTCTAlbum * album = [_model.albums objectOrNilAtIndex:index];
//    if (!album) return NO;
//    return album.isVideo;
//}

//- (NSString *)headerName {
//    return _model.user.nickname;
//}

//- (NSString *)headAgeAndJob {
//    return [NSString joinString:@"·", @(_model.user.age).stringValue, _model.user.career, nil];
//}
//
//- (NSString *)headLocation {
//    return _model.user.address;
//}
//
//- (NSString *)headerPhotoText {
//    return _model.user.photo;
//}
//
- (void)clickHeaderAvatar {
//    [INTCTOpenPageHelper openMyHomeWithUserid:_targetId];
}
//
//- (NSArray<INTCTAlbum *> *)headerPhotoURLS {
//    return _model.albums;
//    //    NSMutableArray * photos = [NSMutableArray array];
//    //    [_model.albums enumerateObjectsUsingBlock:^(INTCTAlbum * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    //        if (obj.link) {
//    //            [photos addObject:obj.link];
//    //        }
//    //    }];
//    //    return photos;
//}

@end
