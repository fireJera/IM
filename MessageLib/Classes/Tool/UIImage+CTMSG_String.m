//
//  UIImage+CTMSG_String.m
//  MessageLib
//
//  Created by Jeremy on 2019/5/27.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "UIImage+CTMSG_String.h"
#import "NSData+CTMSG_Base64.h"

@implementation UIImage (CTMSG_String)

- (NSString *)ctmsg_imageBase64String {
    NSData *data = UIImageJPEGRepresentation(self, 1.0f);
    return [data ctmsg_base64String];
}

@end
