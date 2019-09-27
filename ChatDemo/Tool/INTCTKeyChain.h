//
//  INTCTKeyChain.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const INTCTUUIDKey;

@interface INTCTKeyChain : NSObject

+ (BOOL)saveValue:(id)value ForKey:(NSString *)key;
+ (id)load:(NSString *)key;
+ (BOOL)remove:(NSString *)key;

+ (void)saveUUid;
+ (NSString *)UUId;

@end

NS_ASSUME_NONNULL_END
