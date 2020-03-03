//
//  NSString+CTMSG_Str.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CTMSG_Str)

- (NSString *)turnToCharacters;

- (NSDate *)strToDateBy:(NSString *)format;

- (NSDictionary *)urlParameterToDictionary;

- (id)convertToObject;

- (NSString *)md5String;

- (NSString *)base64String;

- (NSString *)URLEncode;

//计算字符长度
- (int)stringChatLength;

@end

NS_ASSUME_NONNULL_END
