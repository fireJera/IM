//
//  INTCTConersationListViewController.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationListViewController.h"
#import "INTCTConversationListInfoDataSource.h"
#import <MJRefresh/MJRefresh.h>
#import "UIView+INTCT_Frame.h"
#import "UIFont+INTCT_Custom.h"
#import "UIColor+INTCT_App.h"
#import "Header.h"

//#import "UIImage+WebP.h"

static NSString * const kSystemeTargetId = @"10000";

@interface INTCTConversationListViewController ()

@property (nonatomic, strong) UIView * openNotifyView;
@property (nonatomic, strong) UIView * defaultHeaderView;
@property (nonatomic, strong) id<INTCTConversationListInfoDataSource> dataSource;

@end

@implementation INTCTConversationListViewController

- (instancetype)initWithDatasource:(id<INTCTConversationListInfoDataSource>)datasource {
    self = [super init];
    if (!self) return nil;
    _dataSource = datasource;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(p_intct_refreshList:)
//                                                 name:@"RefreshConversationList"
//                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUnlock:) name:INTCTChatListUserUnlockNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_leaveMatch) name:INTCTMatchLeaveNotification object:nil];
    
    [self p_intct_setNavView];
    [self p_intct_refresh];
    [self p_intct_setDataSource];
//    [_dataSource fetchCache];
    [self.conversationListTableView.mj_header beginRefreshing];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
////    self.navBarTitleColor = [UIColor blackTextColor];
////    if (@available(iOS 11.0, *)) {
////        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
////    }
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navBarTitleColor = [UIColor blackTextColor];
    [self.conversationListTableView reloadData];
//    [INTCTOpenPageHelper setUnreadMessageCount:_dataSource.unread];
    
    if (!_defaultHeaderView) {
        _defaultHeaderView = self.conversationListTableView.tableHeaderView;
    }
//    [INTCTAuthorityHelper hasPushAuthority:^(BOOL hasAuth) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (hasAuth) {
//                self.conversationListTableView.tableHeaderView = _defaultHeaderView;
//            }
//            else {
//                self.conversationListTableView.tableHeaderView = self.openNotifyView;
//            }
//        });
//    }];
}

#pragma mark - set view

- (void)p_intct_setNavView {
//    [self intct_setNavView];
    self.navigationItem.title = @"消息";
    self.navigationItem.leftBarButtonItem = nil;
//    self.navBarTintColor = [UIColor navColor];
//    self.navBarTitleColor = [UIColor blackTextColor];
//    self.navBarBgAlpha = 1;
}

- (void)p_set_testBtn {
#if DEBUG
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
#endif
}

- (void)test:(UIButton *)sender {
    
}

- (void)p_intct_setDataSource {
    __weak typeof(self) weakSelf = self;
    [_dataSource setRefreshBlock:^(BOOL needRefresh) {
        if (!weakSelf.dataSource.isCache) {
            [weakSelf.conversationListTableView.mj_header endRefreshing];
            if (weakSelf.dataSource.hasMore) {
                [weakSelf.conversationListTableView.mj_footer endRefreshing];
            } else {
                [weakSelf.conversationListTableView.mj_footer endRefreshingWithNoMoreData];
            }
            if (weakSelf.dataSource.showEmpty) {
//                weakSelf.blankView.blankType = INTCTBlankViewTypeMessage;
//                weakSelf.conversationListTableView.tableFooterView = weakSelf.blankView;
            } else {
                weakSelf.conversationListTableView.tableFooterView = nil;
            }
        }
        if (needRefresh) {
            [weakSelf refreshConversationTableViewIfNeeded];
            //            if (_conversationListDataSource.count == 0) {
            //                    self.conversationListTableView.tableFooterView = self.emptyConversationView;
            //                }
        }
    }];
}

- (void)p_intct_refresh {
    self.conversationListTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchFirst)];
    self.conversationListTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchNext)];
}

#pragma mark - data

- (void)fetchFirst {
    [_dataSource intct_fetchFirstPageData];
}

- (void)fetchNext {
    [_dataSource intct_fetchNextPageData];
}

#pragma mark - UITableViewDataSource

- (void)onSelectedTableRow:(CTMSGConversationModelType)conversationModelType conversationModel:(CTMSGConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
//    [INTCTAliLog putModule:@"INTCTChatListViewController" action:model.targetId];
    if ([model.targetId isEqualToString:kSystemeTargetId]) {
        [_dataSource changeUnread:-model.unreadMessageCount];
        model.unreadMessageCount = 0;
//        [INTCTOpenPageHelper openSystemMessageList];
    } else {
//        [INTCTOpenPageHelper openChatWithTargetId:model.targetId];
    }
    //    [INTCTOpenPageHelper openSystemMessageList];
}

- (BOOL)ctmsg_canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGConversationModel * model = [self.conversationListDataSource objectAtIndex:indexPath.row];
    return ![model.targetId isEqualToString:kSystemeTargetId];
}

- (NSMutableArray<CTMSGConversationModel *> *)willReloadTableData:(NSMutableArray<CTMSGConversationModel *> *)dataSource {
    return _dataSource.messages;
}

- (void)CTMSGConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [INTCTOpenPageHelper intct_showCustomAlertWithTitle:@"是否确认删除？" block:^(INTCTOpenAlert * _Nonnull alert) {
//            alert.canceltitle().cancelStyle();
//            alert.sureTitle().defaultStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//                [_dataSource removeConversationAtIndex:indexPath.row];
//            };
//        }];
    }
}

//- (CGFloat)CTMSGConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

//- (CTMSGConversationBaseCell *)CTMSGConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

//- (void)willDisplayConversationTableCell:(CTMSGConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    static UIImage * image;
//    if (!image) {
////        NSString * name = @"intct_chatlist_ani.webp";
//        NSString * imgPath = [[NSBundle mainBundle] pathForResource:@"intct_chatlist_ani" ofType:@"webp"];
//        NSData * imageData = [NSData dataWithContentsOfFile:imgPath];
//        image = [UIImage sd_imageWithWebPData:imageData];
//    }
//    if ([cell isKindOfClass:CTMSGConversationCell.class]) {
//        if (image) {
//            ((CTMSGConversationCell *)cell).avatarAnimate.image = image;
//        }
//        //        CTMSGConversationModel * conversation = _conversationListDataSource[indexPath.row];
////        (CTMSGConversationCell *)cCell = (CTMSGConversationCell *)cell;
////        [cCell.avatarBtn sd_setImageWithURL:[NSURL URLWithString:conversation.avatar] forState:UIControlStateNormal];
////        cCell.conversationTitle.text = conversation.nickname;
//    }
//}

#pragma mark - CTMSGConversationCellDelegate

- (void)didTapCellAvatar:(CTMSGConversationModel *)model {
//    if ([model.targetId isEqualToString:kSystemeTargetId]) {
//        [INTCTOpenPageHelper openSystemMessageList];
//    } else {
//        [INTCTOpenPageHelper openChatWithTargetId:model.targetId];
//    }
    //    [INTCTOpenPageHelper openChatWithTargetId:model.targetId];
}

#pragma mark - touch event

- (void)p_openPush:(UIButton *)sender {
//    [INTCTAuthorityHelper openPushAuthoritySetting];
}

#pragma mark - notification

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    CTMSGMessage * message = notification.object;
    if (message.content.extraPara) {
        return;
    }
    [super didReceiveMessageNotification:notification];
    //    CTMSGMessage * message = notification.object;
    ////    if ([CTMSGConversationViewController conversationOpenedWithTargetId:message.targetId]) return;
    //    if (self.navigationController.topViewController != self) {
    //        if (message.messageDirection == CTMSGMessageDirectionReceive) {
    //            if (![CTMSGConversationViewController conversationOpenedWithTargetId:message.targetId]) {
    //                [_dataSource changeUnread:1];
    //            }
    //        }
    ////        [self.conversationListDataSource enumerateObjectsUsingBlock:^(CTMSGConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    ////            if ([obj.targetId isEqualToString:message.targetId]) {
    ////                [_dataSource changeUnread:-obj.unreadMessageCount];
    ////                obj.unreadMessageCount = 0;
    ////            }
    ////        }];
    //    } else {
    //        [INTCTOpenPageHelper setUnreadMessageCount:_dataSource.unread];
    //    }
}

- (void)p_leaveMatch {
    [self.conversationListTableView.mj_header beginRefreshing];
}

//- (void)p_intct_refreshList:(NSNotification *)notification {
//
//}

//- (void)userUnlock:(NSNotification *)notification {
//    NSDictionary * dic = notification.userInfo;
//    NSString * userId = dic[@"userid"];
//    [self.conversationListDataSource enumerateObjectsUsingBlock:^(CTMSGConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.targetId isEqualToString:userId]) {
//            obj.isLock = NO;
//            obj.conversationTitle = obj.lastestMessage.conversationDigest;
//            [self.conversationListTableView reloadData];
//            *stop = YES;
//        }
//    }];
//}

#pragma mark - public

- (void)loadConversationDataFromDB {
    if (self.conversationListDataSource.count == 0) {
        [super loadConversationDataFromDB];
        [_dataSource getDBConverstations:self.conversationListDataSource];
    }
}

- (void)didDeleteConversationCell:(CTMSGConversationModel *)model {
    
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [self.conversationListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//- (CTMSGConversationBaseCell *)CTMSGConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {=
//    return [tableView dequeueReusableCellWithIdentifier:kConversationCell forIndexPath:indexPath];
//}

//- (CGFloat)CTMSGConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return kCellHeight;
//}

//- (void)refreshConversationTableViewIfNeeded {
//    [super refreshConversationTableViewIfNeeded];
//}

- (void)refreshConversationTableViewWithConversationModel:(CTMSGConversationModel *)conversationModel {
    if (!conversationModel) return;
    __block NSUInteger insertIndex = 0;
    __block BOOL has = NO;
    __block BOOL needCompare = YES;
    __block CTMSGConversationModel * model;
//    BOOL isVip = conversationModel.lastestMessage.senderUserInfo.isVip;
    //    if ([conversationModel.targetId isEqualToString:kSystemeTargetId]) {
    //        CTMSGConversationModel * first = [self.conversationListDataSource objectOrNilAtIndex:0];
    //        if ([first.targetId isEqualToString:kSystemeTargetId]) {
    //            [self.conversationListDataSource replaceObjectAtIndex:0 withObject:conversationModel];
    //        }
    //    } else {
    [self.conversationListDataSource enumerateObjectsUsingBlock:^(CTMSGConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetId isEqualToString:conversationModel.targetId]) {
            has = YES;
//            if (obj.isLock && conversationModel.lastestMessageDirection == CTMSGMessageDirectionReceive) {
//                obj.conversationTitle = @"发来了新的消息，点击查看~";
//            } else {
                obj.conversationTitle = conversationModel.conversationTitle;
//            }
            obj.unreadMessageCount += conversationModel.unreadMessageCount;
            obj.receivedTime = conversationModel.receivedTime;
            //                obj.sentTime = conversationModel.sentTime;
            if (conversationModel.lastestMessage.senderUserInfo == nil) {
                conversationModel.lastestMessage.senderUserInfo = obj.lastestMessage.senderUserInfo;
            }
            obj.showTime = conversationModel.showTime;
            obj.lastestMessage = conversationModel.lastestMessage;
            obj.lastestMessageId = conversationModel.lastestMessageId;
            obj.lastestMessageDirection = conversationModel.lastestMessageDirection;
            [self.conversationListDataSource removeObject:obj];
            model = obj;
        }
        if (needCompare) {
//            if (isVip) {
//                if (obj.lastestMessage.senderUserInfo.isVip) {
//                    if (conversationModel.sentTime > obj.sentTime) {
//                        insertIndex = idx;
//                        obj.sentTime = conversationModel.sentTime;
//                        needCompare = NO;
//                    }
//                } else {
//                    insertIndex = idx;
//                    obj.sentTime = conversationModel.sentTime;
//                    needCompare = NO;
//                }
//            } else {
//                if (!obj.lastestMessage.senderUserInfo.isVip) {
                    if (conversationModel.sentTime > obj.sentTime) {
                        insertIndex = idx;
                        obj.sentTime = conversationModel.sentTime;
                        needCompare = NO;
                    }
//                }
//            }
        }
    }];
    //    }
    //    [_dataSource changeUnread:conversationModel.unreadMessageCount];
    if (model) {
        conversationModel = model;
    }
    if (insertIndex == 0) {
        CTMSGConversationModel * first = [self.conversationListDataSource objectAtIndex:0];
        if ([first.targetId isEqualToString:kSystemeTargetId]) {
            insertIndex = 1;
        }
    }
    if ([conversationModel.targetId isEqualToString:kSystemeTargetId]) {
        insertIndex = 0;
    }
    [self.conversationListDataSource insertObject:conversationModel atIndex:insertIndex];
    if (self.navigationController.topViewController != self) return;
    if (has) {
        [self.conversationListTableView reloadData];
    } else {
        //        [self.conversationListDataSource addObject:conversationModel];
        [self.conversationListTableView beginUpdates];
        [self.conversationListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.conversationListTableView endUpdates];
    }
}


- (void)notifyUpdateUnreadMessageCount {
    [self updateBadgeValueForTabBarItem];
}

- (void)updateBadgeValueForTabBarItem {
    
}
//
//- (void)ctmsg_conversationUnreadPlusOne {
//    [_dataSource changeUnread:1];
//}

#pragma mark - private

//- (void)p_ctmsg_resetCellDeleteBtn {
//    // 获取选项按钮的reference
//    if (IOS11_OR_LATER)
//    {
//        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
//        for (UIView *subview in self.conversationListTableView.subviews)
//        {
//            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")])
//            {
//                CGRect frame = subview.frame;
//                frame.origin.y += 5;
//                frame.size.height -= 10;
//                subview.frame = frame;
//                subview.layer.cornerRadius = 5;
//            }
//        }
//    }
//    else
//    {
//        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
//        UITableViewCell *cell = [self.conversationListTableView cellForRowAtIndexPath:_editIndexPath];
//        for (UIView *subview in cell.subviews)
//        {
//            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")])
//            {
//                CGRect frame = subview.frame;
//                frame.origin.y += 5;
//                frame.size.height -= 10;
//                subview.frame = frame;
//                subview.layer.cornerRadius = 5;
//            }
//        }
//    }
//}

#pragma mark - lazy
- (UIView *)openNotifyView {
    if (!_openNotifyView) {
        _openNotifyView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.view.width, 32}];
        _openNotifyView.backgroundColor = [UIColor color_ff9191];
        UILabel * label = [[UILabel alloc] init];
//
//        [INTCTViewHelper intct_labelWithFrame:CGRectZero
//                                                          title:@"开启消息通知，不错过任何一个消息~"
//                                                           font:[UIFont systemFontOfSize:14]
//                                                      textColor:[UIColor whiteColor]];
        [label sizeToFit];
        label.left = 14;
        label.centerY = _openNotifyView.height / 2;
        [_openNotifyView addSubview:label];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(_openNotifyView.width - 60 -14, 4, 60, 24);
        [button addTarget:self action:@selector(p_openPush:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
//        [INTCTViewHelper intct_buttonWithFrame:CGRectMake(_openNotifyView.width - 60 -14, 4, 60, 24)
//                                                           bgImage:nil
//                                                             image:nil
//                                                             title:@"开启"
//                                                         textColor:[UIColor color_ff9191]
//                                                            method:@selector(p_openPush:)
//                                                            target:self];
        button.titleLabel.font = [UIFont intct_PingFangMedium12];
        button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        button.layer.cornerRadius = 12;
        [_openNotifyView addSubview:button];
    }
    return _openNotifyView;
}

//
//- (UIView *)emptyConversationView {
//    if (!_emptyConversationView) {
//        _emptyConversationView = [[UIView alloc] initWithFrame:self.conversationListTableView.bounds];
//        _emptyConversationView.backgroundColor = [UIColor redColor];
//        _emptyConversationView.alpha = 1;
//    }
//    return _emptyConversationView;
//}

//- (CTMSGNetworkIndicatorView *)networkIndicatorView {
//    if (!_networkIndicatorView) {
//        _networkIndicatorView = [[CTMSGNetworkIndicatorView alloc] init];
//    }
//    return _networkIndicatorView;
//}

#pragma mark - init

//- (UIStatusBarStyle)preferredStatusBarStyle {
//setNeedsStatusBarAppearanceUpdate
//    return UIStatusBarStyleLightContent;
//}

@end
