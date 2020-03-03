//
//  CTMSGSearchConversationResult.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTMSGConversation;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGSearchConversationResult : NSObject

/*!
 会话
 */
@property(nonatomic, strong) CTMSGConversation *conversation;

/*
 匹配的条数
 */
@property(nonatomic, assign) int matchCount;

@end

NS_ASSUME_NONNULL_END
