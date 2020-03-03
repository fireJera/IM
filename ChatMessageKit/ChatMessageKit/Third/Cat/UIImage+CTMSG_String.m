//
//  UIImage+CTMSG_String.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "UIImage+CTMSG_String.h"

@implementation UIImage (CTMSG_String)

- (NSString *)ctmsg_convertToBase64String {
    NSData * data = UIImageJPEGRepresentation(self, 1);
    NSString * str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return str;
}

@end
