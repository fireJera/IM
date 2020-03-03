//
//  NSData+CTMSG_Data.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "NSData+CTMSG_Data.h"

@implementation NSData (CTMSG_Data)

- (NSString *)base64String;
{
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

- (NSString *)mimeType {
    uint8_t c;
    [self getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg";
            break;
        case 0x89:
            return @"png";
            break;
        case 0x47:
            return @"gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

@end
