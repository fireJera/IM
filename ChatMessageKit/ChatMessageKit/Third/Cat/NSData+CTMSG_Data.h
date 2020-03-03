//
//  NSData+CTMSG_Data.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CTMSG_Data)

- (NSString *)base64String;

- (NSString *)mimeType;

@end

NS_ASSUME_NONNULL_END
