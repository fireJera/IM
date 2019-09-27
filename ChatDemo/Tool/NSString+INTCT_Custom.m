//
//  NSString+INTCT_Custom.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSString+INTCT_Custom.h"
//#import "UIImage+INTCT_Custom.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+INTCT_Custom.h"
#import "Header.h"

@implementation NSString (INTCT_Custom)

- (NSString *)turnToCharacters {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString: self];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    //返回小写拼音
    return [str lowercaseString];
}

- (NSDate *)strToDateBy:(NSString *)format {
    NSDateFormatter * formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    return [formatter dateFromString:self];
}

- (NSDictionary *)urlParameterToDictionary {
    NSArray * array = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:array.count];
    for (NSString * str in array) {
        NSArray * parameter = [str componentsSeparatedByString:@"="];
        if (parameter.count > 1) {
            [dic setValue:parameter[1] forKey:parameter.firstObject];
        }
    }
    return dic;
}

- (id)convertToObject {
    if (self == nil) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                  error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return object;
}

- (NSString *)md5String {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return [result lowercaseString];
}

- (NSString *)base64String {
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64String];
}

- (NSString *)URLEncode
{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString * encodedStr = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedStr;
}

- (NSString *)subStringIndex:(NSInteger)index {
    NSString *result = self;
    if (result.length > index) {
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    return result;
}

- (NSString *)stringByTrim {
    NSCharacterSet * character = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:character];
}

//判断中英混合的的字符串长度
- (int)stringChatLength {
    int strlength = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

//验证纯数字短信验证码 numberCount：验证码的数字个数
+ (BOOL)checkLegallityOfVerificationCode:(NSString *)code numberCount:(NSInteger)numberCount{
    NSString *regex = [NSString stringWithFormat:@"^[0-9]{%ld}$",(long)numberCount];
    return [self matchByString:code regexString:regex];
}

+ (BOOL)matchByString:(NSString*)string regexString:(NSString *)regexStr{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexStr];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (NSMutableArray *)matchedStrGroup:(NSString *)string regexString:(NSString *)regexStr{
    NSMutableArray* resultArray = [NSMutableArray array];
    /*使用NSRegularExpression :进行正则匹配*/
    // 格式一：寻找所有符合格式的子串
    NSString *text = string;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for(NSTextCheckingResult *b in array)
    {
        NSString *str = [text substringWithRange:b.range];
        [resultArray addObject:str];
    }
    
    return resultArray;
}

+ (instancetype)joinString:(NSString *)joinStr, ... {
    va_list args;
    NSMutableArray * array = [NSMutableArray array];
    va_start(args, joinStr);
    NSString * first = va_arg(args, id);
    for (id string = first; string != nil; string = va_arg(args, id)) {
        if ([string isKindOfClass:[NSString class]]) {
            if (IsStringLengthGreaterThanZero(string)) {
                [array addObject:string];
            }
        }
    }
    va_end(args);
    NSString *string;
    if (IsArrayWithItems(array)) {
        string = [array componentsJoinedByString:joinStr];
    }
    return string;
}

@end

@implementation NSString (INTCT_Image)

- (UIImage *)intct_convertToUIImage {
    NSData * data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage * image = [UIImage imageWithData:data];
    return image;
}

@end
