//
//  NSString+INTCT_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (INTCT_Custom)

/**
 NS_FORMAT_FUNCTION(1,2)
 __attribute__((format(__NSString__,F, A))) F位是格式化字符串 从A位开始检查
 如果某个参数是nil 或者长度为0 跳过
 @param joinStr 拼接的分割字符串  如果将@"1"和@"2" 拼接成@"1, 2" 传入@","
 @return string
 */
+ (instancetype)joinString:(NSString *)joinStr, ... NS_REQUIRES_NIL_TERMINATION;

- (NSString *)turnToCharacters;

- (NSDate *)strToDateBy:(NSString *)format;

- (NSDictionary *)urlParameterToDictionary;

- (id)convertToObject;

- (NSString *)md5String;

- (NSString *)base64String;

- (NSString *)URLEncode;

- (NSString *)stringByTrim;

//计算字符长度
- (int)stringChatLength;

/**
 *  验证纯数字短信验证码 numberCount：验证码的数字个数
 *
 **/
+ (BOOL)checkLegallityOfVerificationCode:(NSString *)code numberCount:(NSInteger)numberCount;

@end

@interface NSString (INTCT_Image)

- (UIImage *)intct_convertToUIImage;

@end

NS_ASSUME_NONNULL_END
