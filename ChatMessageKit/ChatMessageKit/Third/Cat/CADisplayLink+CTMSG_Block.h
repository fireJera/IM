//
//  CTMSG_Block.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CMTSGExecuteDisplayLinkBlock) (CADisplayLink *displayLink);

@interface CADisplayLink (CTMSG_Block)

@property (nonatomic, copy)CMTSGExecuteDisplayLinkBlock executeBlock;

+ (CADisplayLink *)displayLinkWithExecuteBlock:(CMTSGExecuteDisplayLinkBlock)block;


@end

NS_ASSUME_NONNULL_END
