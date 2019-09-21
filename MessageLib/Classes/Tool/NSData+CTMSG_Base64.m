//
//  NSData+CTMSG_Base64.m
//  MessageLib
//
//  Created by Jeremy on 2019/5/27.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSData+CTMSG_Base64.h"
#import <UIKit/UIKit.h>
//#include <CommonCrypto/CommonCrypto.h>

@implementation NSData (CTMSG_Base64)

- (NSString *)ctmsg_base64String {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        const uint8_t* input = (const uint8_t*)[self bytes];
        NSInteger length = [self length];
        
        static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        
        NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
        uint8_t* output = (uint8_t*)data.mutableBytes;
        
        NSInteger i;
        for (i=0; i < length; i += 3) {
            NSInteger value = 0;
            NSInteger j;
            for (j = i; j < (i + 3); j++) {
                value <<= 8;
                
                if (j < length) {
                    value |= (0xFF & input[j]);
                }
            }
            
            NSInteger theIndex = (i / 3) * 4;
            output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
            output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
            output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
            output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
        }
        
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] ;
    } else {
        return [self base64EncodedStringWithOptions:0];
    }
}

@end
