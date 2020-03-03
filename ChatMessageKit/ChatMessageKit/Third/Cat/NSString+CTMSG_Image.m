//
//  NSString+CTMSG_Image.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "NSString+CTMSG_Image.h"

@implementation NSString (CTMSG_Image)

- (UIImage *)ctmsg_convertToUIImage {
    NSData * data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage * image = [UIImage imageWithData:data];
    return image;
}

@end
