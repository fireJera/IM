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

#import "CTMSGTextMessage.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGImageMessage.h"
#import "CTMSGVideoMessage.h"
#import "CTMSGUserInfo.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"
#import "CTMSGIMClient.h"
#import "CTMSGConversationViewController.h"
#import "CTMSGUtilities.h"
#import "CTMSGIM.h"
#import "CTMSGNetManager.h"
#import "CTMSGMessage.h"
#import "CTMSGNetConversationModel.h"
#import "CTMSGNetMessageModel.h"

#if __has_include (<YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

#define LOCK dispatch_semaphore_wait(_arrayLock, DISPATCH_TIME_FOREVER);
#define UNLOCK dispatch_semaphore_signal(_arrayLock);

static const int kCellHeight = 86;

static NSString * const kConversationCell = @"conversationCell";

@interface CTMSGConversationListController () <CTMSGConversationCellDelegate> {
    NSIndexPath * _editIndexPath;
    NSString * _lastId;
    BOOL _hasMore;
    NSInteger _currentPage;
}

@property (nonatomic, strong) dispatch_semaphore_t arrayLock;

@end

@implementation CTMSGConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_ctmsg_init];
    self.title = @"消息";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:CTMSGKitDispatchMessageNotification object:nil];
    
//    [CTMSGNetManager startMonitoringNet:^{
//        if (![CTMSGNetManager netReachable]) {
//            if (_isShowNetworkIndicatorView) {
//                //TODO: - show net view
//                _conversationListTableView.tableHeaderView = self.networkIndicatorView;
//            }
//        } else {
//                _conversationListTableView.tableHeaderView = nil;
//        }
//    }];
    [self p_ctmsg_setView];
//#if DEBUG
//    [self p_makeFakeData];
//#else
    [self p_ctmsg_fetchData];
//#endif
    [self p_set_testBtn];
}

//- (void)p_makeFakeData {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        LOCK
//        for (int i = 0; i < 10; i++) {
//            CTMSGConversationModel * conversation = [[CTMSGConversationModel alloc] init];
//            conversation.conversationModelType = CTMSG_CONVERSATION_MODEL_TYPE_NORMAL;
//            conversation.targetId = @"10657873";
//            conversation.conversationTitle = @"jeremy";
//            conversation.unreadMessageCount = 1;
//            conversation.isTop = YES;
//            conversation.receivedTime = [[NSDate date] timeIntervalSince1970];
//            conversation.objectName = CTMSGTextMessageTypeIdentifier;
//            conversation.senderUserId = @"5036823";
//            conversation.lastestMessageId = 14;
//            CTMSGTextMessage * text = [[CTMSGTextMessage alloc] init];
//            text.content = @"this is a text message";
//            text.extra = @"extra";
//            conversation.lastestMessageDirection = CTMSGMessageDirectionReceive;
//            conversation.lastestMessage = text;
//            CTMSGUserInfo * user = [[CTMSGUserInfo alloc] init];
//            user.userId = @"5036823";
//            user.name = @"Tend";
//            text.senderUserInfo = user;
//            [_conversationListDataSource addObject:conversation];
//        }
//        _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
//        UNLOCK;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_conversationListTableView reloadData];
//            if (_emptyConversationView) {
//                _conversationListTableView.tableFooterView = _emptyConversationView;
//            }
//        });
//    });
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
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

- (void)p_set_testBtn {
#if DEBUG
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(test:)];
#endif
}

- (void)test:(UIButton *)sender {
    
}

- (void)p_ctmsg_setView {
    _emptyConversationView = [[UIView alloc] init];
    
    _conversationListTableView = [[UITableView alloc] init];
    _conversationListTableView.backgroundColor = [UIColor ctmsg_themeGrayColor];
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

- (void)p_ctmsg_fetchData {
    LOCK
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<CTMSGConversation *> * array = [[CTMSGIMClient sharedCTMSGIMClient] getConversationList:nil count:100 startTime:0];
        [array enumerateObjectsUsingBlock:^(CTMSGConversation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CTMSGConversationModel * model = [[CTMSGConversationModel alloc] initWithConversation:obj extend:nil];
            [_conversationListDataSource addObject:model];
        }];
//        [_conversationListDataSource addObjectsFromArray:array];
    });
    _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
    UNLOCK
    dispatch_async(dispatch_get_main_queue(), ^{
        [_conversationListTableView reloadData];
        if (_emptyConversationView) {
            _conversationListTableView.tableFooterView = _emptyConversationView;
        }
    });
}

- (void)p_ctmsg_fetchNetData {
    [CTMSGNetManager getConversationListLastId:_lastId success:^(id  _Nonnull response) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            _currentPage++;
            NSDictionary * result = (NSDictionary *)response;
            _hasMore = [result[@"hasMore"] boolValue];
            _lastId =  [NSString stringWithFormat:@"%@", result[@"lastId"]];
            NSArray * array = result[@"list"];
            NSMutableArray<CTMSGConversationModel *> * conversations = [NSMutableArray array];
            for (NSDictionary * dic in array) {
                CTMSGNetConversationModel * model = [CTMSGNetConversationModel yy_modelWithJSON:dic];
                CTMSGConversationModel * cModel = [model copy];
                [conversations addObject:cModel];
            }
            
            LOCK
            if (_currentPage == 0) {
                _conversationListDataSource = conversations;
            } else {
                [_conversationListDataSource addObjectsFromArray:conversations];
            }
            _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
            UNLOCK
            dispatch_async(dispatch_get_main_queue(), ^{
                [_conversationListTableView reloadData];
                if (_emptyConversationView) {
                    _conversationListTableView.tableFooterView = _emptyConversationView;
                }
            });
        }
    } failure:^(NSError * _Nonnull err) {
        
    }];
}

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
    return YES;
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
    model.unreadMessageCount = 1;
    model.conversationTitle = [message.content conversationDigest];
    model.targetId = message.messageDirection == CTMSGMessageDirectionSend ? message.targetId : message.senderUserId;
    model.sentTime = message.sentTime;
    model.receivedTime = message.receivedTime;
    model.lastestMessage = message.content;
    model.lastestMessageId = message.messageId;
    model.lastestMessageDirection = message.messageDirection;
    [self refreshConversationTableViewWithConversationModel:model];
}

#pragma mark - public

- (void)onSelectedTableRow:(CTMSGConversationModelType)conversationModelType conversationModel:(CTMSGConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    CTMSGConversationViewController * conversation = [[CTMSGConversationViewController alloc] initWithConversationType:model.conversationType targetId:model.targetId];
    conversation.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversation animated:YES];
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

- (void)refreshConversationTableViewIfNeeded {
//#if DEBUG
//    [self p_makeFakeData];
//#else
//    [self p_ctmsg_fetchData];
    [self p_ctmsg_fetchNetData];
//#endif
}

- (void)refreshConversationTableViewWithConversationModel:(CTMSGConversationModel *)conversationModel {
    __block BOOL has = NO;
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
            *stop = YES;
        } else if (conversationModel.sentTime > obj.sentTime) {
            insertIndex = idx;
        }
    }];
    if (has) {
        [_conversationListTableView beginUpdates];
        [_conversationListTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_conversationListTableView endUpdates];
    } else {
        [_conversationListDataSource addObject:conversationModel];
        [_conversationListTableView beginUpdates];
        [_conversationListTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_conversationListTableView endUpdates];
    }
}

- (void)notifyUpdateUnreadMessageCount {
    
}

#pragma mark - private

- (void)p_ctmsg_resetCellDeleteBtn
{
    // 获取选项按钮的reference
    if (IOS11_OR_LATER)
    {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.conversationListTableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")])
            {
                CGRect frame = subview.frame;
                frame.origin.y += 5;
                frame.size.height -= 10;
                subview.frame = frame;
                subview.layer.cornerRadius = 5;
            }
        }
    }
    else
    {
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
                subview.layer.cornerRadius = 5;
            }
        }
    }
}

#pragma mark - lazy

//- (UIView *)emptyConversationView {
//    if (!_emptyConversationView) {
//        _emptyConversationView = [[UIView alloc] init];
//    }
//    return _emptyConversationView;
//}

- (CTMSGNetworkIndicatorView *)networkIndicatorView {
    if (!_networkIndicatorView) {
        _networkIndicatorView = [[CTMSGNetworkIndicatorView alloc] init];
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
//    [CTMSGIM sharedCTMSGIM]
    _lastId = nil;
    _currentPage = 0;
    _arrayLock = dispatch_semaphore_create(1);
    _conversationListDataSource = [NSMutableArray array];
}

@end
