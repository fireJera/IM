//
//  INTCTConversationDataSource.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#ifndef INTCTConversationDataSource_h
#define INTCTConversationDataSource_h
#import "Header.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, INTCTConversationFrom) {
    INTCTConversationNormal,
    INTCTConversationMatch,
};

#import "INTCTViewControllerInfoDataSource.h"

@class CTMSGMessage, CTMSGMessageModel;

@protocol INTCTConversationDataSource <INTCTViewControllerInfoDataSource>

@optional
@property (nonatomic, assign) INTCTConversationFrom conversationFrom;

@property (nonatomic, copy, readonly) NSDictionary * uploadConfig;
//@property (nonatomic, copy, readonly) NSString * messageLockText;
//@property (nonatomic, copy, readonly) NSString * inputLockNote;
//@property (readonly) NSString * unlockAlert;

@property (nonatomic, copy, readonly) NSString * nickname;
@property (nonatomic, copy, readonly) NSURL * avatarURL;
@property (nonatomic, copy, readonly) NSURL * selfAvatarURL;
@property (readonly) NSString * avatar;
//@property (readonly) BOOL isVip;

@property (nonatomic, readonly) BOOL needPlayFlower;
@property (nonatomic, readonly) BOOL didFavored;
//@property (nonatomic, readonly) BOOL messageLock;

/// match
@property (nonatomic, readonly) NSUInteger countDonwTime;
@property (nonatomic, readonly) NSString * countDonwTitle;
@property (nonatomic, readonly) NSArray<NSString *> * quickTexts;
@property (nonatomic, readonly) NSString *matchTopNote;
///

//@property (readonly) BOOL isRefreshing;

@property (readonly) NSArray<CTMSGMessage *> * serverMessages;

- (id)initWithTargetId:(NSString *)targetId;
- (id)initWithConverstaionFrom:(INTCTConversationFrom)conversationFrom targetId:(NSString *)targetId;

- (void)beginTimerWith:(INTCTVoidBlock)timerBlock;

- (void)leaveMatch;

- (void)readAllMessage;

- (void)clickMore;
//- (void)unlockMessage;
- (void)clickNavAvatar;
- (void)deleteMessage:(CTMSGMessageModel *)model resultBlock:(void(^)(NSError * error))resultBlock;

- (void)clickFavor;

- (void)receiveMatchFavor;
- (void)receiveMatchOut;

@end
#endif /* INTCTConversationDataSource_h */
