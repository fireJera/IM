//
//  NSTimer+CTMSG_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (CTMSG_Block)

+ (NSTimer *)ctmsg_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block;

@end

typedef void(^CTMSGExecuteDisplayLinkBlock) (CADisplayLink *displayLink);

@interface CADisplayLink (CTMSG_Block)

@property (nonatomic,copy)CTMSGExecuteDisplayLinkBlock executeBlock;

+ (CADisplayLink *)displayLinkWithExecuteBlock:(CTMSGExecuteDisplayLinkBlock)block;

@end

NS_ASSUME_NONNULL_END
