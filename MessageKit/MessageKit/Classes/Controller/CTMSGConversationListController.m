//
//  CTMSGConversationListController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationListController.h"
#import "CTMSGConversationCell.h"
#import "CTMSGNetworkIndicatorView.h"
#import "CTMSGConversationModel.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGConversationViewController.h"
#import "CTMSGUtilities.h"
#import "CTMSGIM.h"

#import <MessageLib/CTMSGNetManager.h>
#import <MessageLib/CTMSGMessage.h>
#import <MessageLib/CTMSGUserInfo.h>
#import <MessageLib/CTMSGIMClient.h>

#define LOCK dispatch_semaphore_wait(_arrayLock, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_arrayLock);

static const int kCellHeight = 86;

static NSString * const kConversationCell = @"conversationCell";

@interface CTMSGConversationListController () <CTMSGConversationCellDelegate> {
    NSIndexPath * _editIndexPath;
    NSInteger _currentPage;
}

@property (nonatomic, strong) dispatch_semaphore_t arrayLock;

@end

@implementation CTMSGConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_ctmsg_init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:CTMSGKitDispatchMessageNotification object:nil];
    [CTMSGNetManager startMonitoringNet:^{
        if (![CTMSGNetManager netReachable]) {
            if (_isShowNetworkIndicatorView) {
                _conversationListTableView.tableHeaderView = self.networkIndicatorView;
            }
        } else {
                _conversationListTableView.tableHeaderView = nil;
        }
    }];
    [self p_ctmsg_setView];
    [self refreshConversationTableViewIfNeeded];
//    [self p_set_testBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_conversationListTableView reloadData];
//    [_viewmodel intct_notifyRefrehBadge];
}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _conversationListTableView.frame = (CGRect){0, 0, self.view.bounds.size.width, self.view.bounds.size.height - CTMSGBottomHeight};
    if (_emptyConversationView) {
        _emptyConversationView.frame = self.view.bounds;
    }
    if (_networkIndicatorView) {
        _networkIndicatorView.frame = (CGRect){0, 0, self.view.frame.size.width, 60};
    }
    if (_editIndexPath)
    {
        [self p_ctmsg_resetCellDeleteBtn];
    }
}

#pragma mark - set view

- (void)p_ctmsg_setView {
    _conversationListTableView = [[UITableView alloc] init];
    _conversationListTableView.backgroundColor = [UIColor ctmsg_colorWithRGB:0xf3f6fb];
    [self.view addSubview:_conversationListTableView];
    _conversationListTableView.dataSource = self;
    _conversationListTableView.delegate = self;
    _conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_conversationListTableView registerClass:[CTMSGConversationCell class] forCellReuseIdentifier:kConversationCell];
    _conversationListTableView.tableFooterView = [UIView new];
//    if (@available(iOS 11.0, *)) {
//        _conversationListTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
}

#pragma mark - data

//- (void)p_ctmsg_fetchNetData {
//    NSArray * array;
////    [[CTMSGIMClient sharedCTMSGIMClient] getConversationList:array count:20 startTime:0];
//    [CTMSGNetManager getConversationListLastId:_lastId success:^(id  _Nonnull response) {
//        if ([response isKindOfClass:[NSDictionary class]]) {
//            NSDictionary * result = (NSDictionary *)response;
//            _hasMore = [result[@"data"][@"hasMore"] boolValue];
//            _lastId =  [NSString stringWithFormat:@"%@", result[@"data"][@"lastId"]];
//            NSArray * array = result[@"data"][@"list"];
//            NSMutableArray<CTMSGConversationModel *> * conversations = [NSMutableArray array];
//            for (NSDictionary * dic in array) {
//                CTMSGNetConversationModel * model = [CTMSGNetConversationModel yy_modelWithJSON:dic];
//                CTMSGConversationModel * cModel = [model copy];
//                [conversations addObject:cModel];
//            }
//
//            LOCK
//            if (_currentPage == 0) {
//                _conversationListDataSource = conversations;
//            } else {
//                [_conversationListDataSource addObjectsFromArray:conversations];
//            }
//            _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
//            UNLOCK
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_conversationListTableView reloadData];
//                if (_conversationListDataSource.count == 0) {
//                    _conversationListTableView.tableFooterView = self.emptyConversationView;
//                }
//            });
//            _currentPage++;
//        }
//        [self p_ctmsg_resetMJ];
//    } failure:^(NSError * _Nonnull err) {
//        [self p_ctmsg_resetMJ];
//    }];
//}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _conversationListDataSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CTMSGConversationBaseCell class]]) {
        [self willDisplayConversationTableCell:(CTMSGConversationBaseCell *)cell atIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOCK
    if (indexPath.row < _conversationListDataSource.count) {
        CTMSGConversationModel * conversation = _conversationListDataSource[indexPath.row];
        UNLOCK
        if (conversation.conversationModelType == CTMSG_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
            return [self CTMSGConversationListTableView:tableView cellForRowAtIndexPath:indexPath];
        }
        else {
            CTMSGConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell forIndexPath:indexPath];
            cell.model = conversation;
            cell.delegate = self;
            return cell;
        }
    } else {
        UNLOCK
    }
    return [UITableViewCell new];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    LOCK
    if (indexPath.row < _conversationListDataSource.count) {
        CTMSGConversationModel * conversation = _conversationListDataSource[indexPath.row];
        [self onSelectedTableRow:conversation.conversationModelType
               conversationModel:conversation
                     atIndexPath:indexPath];
    }
//    UNLOCK
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOCK
    if (indexPath.row < _conversationListDataSource.count) {
        CTMSGConversationModel * conversation = _conversationListDataSource[indexPath.row];
        UNLOCK
        if (conversation.conversationModelType == CTMSG_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
            return [self CTMSGConversationListTableView:tableView heightForRowAtIndexPath:indexPath];
        }
        else {
            return kCellHeight;
        }
    } else {
       UNLOCK
    }
    return kCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self ctmsg_canEditRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self CTMSGConversationListTableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    return @[action];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    _editIndexPath = indexPath;
    [self.view setNeedsLayout];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    _editIndexPath = nil;
}

#pragma mark - CTMSGConversationCellDelegate

- (void)didTapCellAvatar:(CTMSGConversationModel *)model {
    
}

#pragma mark - touch event

#pragma mark - notification

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    CTMSGMessage * message = notification.object;
    CTMSGConversationModel * model = [[CTMSGConversationModel alloc] init];
    if (message.messageDirection == CTMSGMessageDirectionReceive) {
        if (![CTMSGConversationViewController conversationOpenedWithTargetId:message.targetId]) {
            model.unreadMessageCount = 1;
        }
    }
    model.isLock = message.isLock;
    if (model.isLock) {
        model.conversationTitle = message.lockNote;
    } else {
        model.conversationTitle = [message.content conversationDigest];
    }
    if (message.content.senderUserInfo) {
        model.isTop = message.content.senderUserInfo.isVip;
    }
    model.targetId = message.messageDirection == CTMSGMessageDirectionSend ? message.targetId : message.senderUserId;
    model.sentTime = message.sentTime;
    model.receivedTime = message.receivedTime;
    model.lastestMessage = message.content;
    model.lastestMessageId = message.messageId;
    model.lastestMessageDirection = message.messageDirection;
    model.showTime = @"刚刚";
    [self refreshConversationTableViewWithConversationModel:model];
}

#pragma mark - public

- (void)onSelectedTableRow:(CTMSGConversationModelType)conversationModelType conversationModel:(CTMSGConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    CTMSGConversationViewController * conversation = [[CTMSGConversationViewController alloc] initWithConversationType:model.conversationType targetId:model.targetId];
//    conversation.showHeadInfo = YES;
    conversation.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversation animated:YES];
}

- (BOOL)ctmsg_canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)didDeleteConversationCell:(CTMSGConversationModel *)model {
    
}

- (NSMutableArray<CTMSGConversationModel *> *)willReloadTableData:(NSMutableArray<CTMSGConversationModel *> *)dataSource {
    return dataSource;
}

- (void)willDisplayConversationTableCell:(CTMSGConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [_conversationListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CTMSGConversationBaseCell *)CTMSGConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kConversationCell forIndexPath:indexPath];
}

- (CGFloat)CTMSGConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)CTMSGConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)loadConversationDataFromDB {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSInteger unread = [[CTMSGIMClient sharedCTMSGIMClient] getTotalUnreadCount];
//        NSLog(@"---------conversation unread : %d---------", (int)unread);
        NSArray<CTMSGConversation *> * array = [[CTMSGIMClient sharedCTMSGIMClient] getConversationList:nil count:100 startTime:0];
        [array enumerateObjectsUsingBlock:^(CTMSGConversation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CTMSGConversationModel * model = [[CTMSGConversationModel alloc] initWithConversation:obj extend:nil];
            CTMSGUserInfo * user = [[CTMSGIM sharedCTMSGIM] getUserInfoCache:model.targetId];
            CTMSGMessageContent * content = [CTMSGMessageContent new];
            content.senderUserInfo = user;
            model.lastestMessage = content;
            [_conversationListDataSource addObject:model];
        }];
//    });
}

- (void)refreshConversationTableViewIfNeeded {
    LOCK
    [self loadConversationDataFromDB];
    _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
    UNLOCK
    dispatch_async(dispatch_get_main_queue(), ^{
        [_conversationListTableView reloadData];
        if (_emptyConversationView) {
            _conversationListTableView.tableFooterView = _emptyConversationView;
        }
    });
}

- (void)refreshConversationTableViewWithConversationModel:(CTMSGConversationModel *)conversationModel {
    __block BOOL has = NO;
//    __block CTMSGConversationModel * model;
    __block NSUInteger insertIndex = 0;
    [_conversationListDataSource enumerateObjectsUsingBlock:^(CTMSGConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.targetId isEqualToString:conversationModel.targetId]) {
            has = YES;
            obj.conversationTitle = conversationModel.conversationTitle;
            obj.unreadMessageCount += 1;
            obj.receivedTime = conversationModel.receivedTime;
            obj.sentTime = conversationModel.sentTime;
            obj.lastestMessage = conversationModel.lastestMessage;
            obj.lastestMessageId = conversationModel.lastestMessageId;
            obj.lastestMessageDirection = conversationModel.lastestMessageDirection;
            [_conversationListDataSource removeObject:obj];
            [_conversationListDataSource insertObject:obj atIndex:0];
            *stop = YES;
        } else if (conversationModel.sentTime > obj.sentTime) {
            insertIndex = idx;
        }
    }];
    if (self.navigationController.topViewController != self) return;
    if (!conversationModel) return;
    if (has) {
        [_conversationListTableView reloadData];
//        [_conversationListTableView beginUpdates];
//        [_conversationListTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [_conversationListTableView endUpdates];
    } else {
        [_conversationListDataSource addObject:conversationModel];
        [_conversationListTableView beginUpdates];
        [_conversationListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_conversationListTableView endUpdates];
    }
}

- (void)notifyUpdateUnreadMessageCount {
    
}

- (void)removeConversationFromDBWithTargetId:(NSString *)targetID {
    [[CTMSGIMClient sharedCTMSGIMClient] removeConversation:ConversationType_PRIVATE targetId:targetID];
}

#pragma mark - private

- (void)p_ctmsg_resetCellDeleteBtn {
    // 获取选项按钮的reference
    if (IOS11_OR_LATER) {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.conversationListTableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")])
            {
                CGRect frame = subview.frame;
                frame.origin.y += 5;
                frame.size.height -= 10;
                subview.frame = frame;
                subview.layer.cornerRadius = 8;
            }
        }
    }
    else {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        UITableViewCell *cell = [self.conversationListTableView cellForRowAtIndexPath:_editIndexPath];
        for (UIView *subview in cell.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")])
            {
                CGRect frame = subview.frame;
                frame.origin.y += 5;
                frame.size.height -= 10;
                subview.frame = frame;
                subview.layer.cornerRadius = 8;
            }
        }
    }
}

#pragma mark - lazy

- (UIView *)emptyConversationView {
    if (!_emptyConversationView) {
        _emptyConversationView = [[UIView alloc] initWithFrame:_conversationListTableView.bounds];
        _emptyConversationView.backgroundColor = [UIColor redColor];
        _emptyConversationView.alpha = 1;
    }
    return _emptyConversationView;
}

- (CTMSGNetworkIndicatorView *)networkIndicatorView {
    if (!_networkIndicatorView) {
        _networkIndicatorView = [[CTMSGNetworkIndicatorView alloc] initWithFrame:(CGRect){0, 0, CTMSGSCREENWIDTH, 48}];
    }
    return _networkIndicatorView;
}

#pragma mark - init

//- (instancetype)initWithDisplayConversationTypes:(NSArray *)displayConversationTypeArray collectionConversationType:(NSArray *)collectionConversationTypeArray {
//    self = [super init];
//    if (!self) return nil;
//    _displayConversationTypeArray = displayConversationTypeArray;
//    _collectionConversationTypeArray = collectionConversationTypeArray;
//    return self;
//}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self p_ctmsg_init];
//    }
//    return self;
//}

- (void)p_ctmsg_init {
    _arrayLock = dispatch_semaphore_create(1);
    _isShowNetworkIndicatorView = YES;
    _conversationListDataSource = [NSMutableArray array];
}

@end
