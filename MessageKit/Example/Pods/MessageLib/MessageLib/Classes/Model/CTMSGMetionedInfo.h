////
////  CTMSGMetionedInfo.h
////  ChatMessageKit
////
////  Created by Jeremy on 2019/4/2.
////  Copyright © 2019 JersiZhu. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "CTMSGEnumDefine.h"
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface CTMSGMetionedInfo : NSObject
//
///*!
// @提醒的类型
// */
//@property(nonatomic, assign) CTMSGMentionedType type;
//
///*!
// @的用户ID列表
// 
// @discussion 如果type是@所有人，则可以传nil
// */
//@property(nonatomic, strong) NSArray<NSString *> *userIdList;
//
///*!
// 包含@提醒的消息，本地通知和远程推送显示的内容
// */
//@property(nonatomic, strong) NSString *mentionedContent;
//
///*!
// 是否@了我
// */
//@property(nonatomic, readonly) BOOL isMentionedMe;
//
///*!
// 初始化@提醒信息
// 
// @param type       @提醒的类型
// @param userIdList @的用户ID列表
// @param mentionedContent @ Push 内容
// 
// @return @提醒信息的对象
// */
//- (instancetype)initWithMentionedType:(CTMSGMentionedType)type
//                           userIdList:(NSArray *)userIdList
//                     mentionedContent:(NSString *)mentionedContent;
//
//@end
//
//NS_ASSUME_NONNULL_END
