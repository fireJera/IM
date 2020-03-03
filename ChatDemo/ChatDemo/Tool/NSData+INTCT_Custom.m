//
//  NSData+INTCT_Custom.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSData+INTCT_Custom.h"
#include <CommonCrypto/CommonCrypto.h>

#if __has_include (<SDWebImage/NSData+ImageContentType.h>)
#import <SDWebImage/NSData+ImageContentType.h>
#else
#import "NSData+ImageContentType.h"
#endif

@implementation NSData (INTCT_Custom)

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

- (NSString *)md5String {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)imageDataFormat {
    NSString * type;
    SDImageFormat formatt = [NSData sd_imageFormatForImageData:self];
    if (formatt == SDImageFormatPNG) {
        type = @"png";
    }
    else if (formatt == SDImageFormatGIF) {
        type = @"gif";
    }
    else if (formatt == SDImageFormatJPEG) {
        type = @"jpg";
    }
    else if (formatt == SDImageFormatWebP) {
        type = @"webp";
    }
    else {
        type = @"image";
    }
    return type;
}

@end
