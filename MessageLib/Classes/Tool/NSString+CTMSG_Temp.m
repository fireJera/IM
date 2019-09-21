//
//  NSString+CTMSG_Temp.m
//  MessageLib
//
//  Created by Jeremy on 2019/5/27.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSString+CTMSG_Temp.h"

@implementation NSString (CTMSG_Temp)

- (UIImage *)ctmsg_convertToUIImage {
    NSData * data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage * image = [UIImage imageWithData:data];
    return image;
}


@end
