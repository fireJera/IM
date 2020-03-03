//
//  NSString+CTMSG_Str.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "NSString+CTMSG_Str.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSData+CTMSG_Data.h"

@implementation NSString (CTMSG_Str)

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
    //    NSString *charactersToEscape = @"=,!$&'()*+;@?\n\"<>#\t :/";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString * encodedStr = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedStr;
    //老的废弃的方法。
    //    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8));
}

//+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
//    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
//    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
//    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
//    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                          mutabilityOption:NSPropertyListImmutable
//                                                                    format:NULL
//                                                          errorDescription:NULL];
//
//    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
//}
//
//- (NSString *)unicodeToString {
//    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
//    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
//    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
//    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                          mutabilityOption:NSPropertyListImmutable
//                                                                    format:NULL
//                                                          errorDescription:NULL];
//
//    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
//}

- (NSString *)subStringIndex:(NSInteger)index {
    NSString *result = self;
    if (result.length > index) {
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    return result;
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

@end
