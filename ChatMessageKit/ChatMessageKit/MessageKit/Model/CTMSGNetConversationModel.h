//
//  CTMSGNetConversationModel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGNetConversationModel : NSObject

@property (nonatomic, copy) NSString * userid;
@property (nonatomic, copy) NSString * targetId;
@property (nonatomic, assign) NSInteger msgType;  //消息类型。如果 toUserid=1000 并且 type=1000  这个可以确定为系统消息
@property (nonatomic, assign) NSInteger unread;
@property (nonatomic, copy) NSString * time;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, assign) BOOL isVip;

@end

NS_ASSUME_NONNULL_END
