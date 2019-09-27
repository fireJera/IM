//
//  NSData+INTCT_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (INTCT_Custom)

@property (readonly) NSString * imageDataFormat;

- (NSString *)base64String;

- (NSString *)md5String;

@end

NS_ASSUME_NONNULL_END
