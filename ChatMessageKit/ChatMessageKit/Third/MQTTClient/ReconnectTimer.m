//
//  ReconnectTimer.m
//  MQTTClient
//
//  Created by Josip Cavar on 22/08/2017.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import "ReconnectTimer.h"
#import "GCDTimer.h"

@interface ReconnectTimer()

@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, assign) NSTimeInterval retryInterval;
@property (nonatomic, assign) NSTimeInterval currentRetryInterval;
@property (nonatomic, assign) NSTimeInterval maxRetryInterval;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (copy, nonatomic) void (^reconnectBlock)(void);

@end

@implementation ReconnectTimer

- (instancetype)initWithRetryInterval:(NSTimeInterval)retryInterval
                     maxRetryInterval:(NSTimeInterval)maxRetryInterval
                                queue:(dispatch_queue_t)queue
                       reconnectBlock:(void (^)(void))block {
    self = [super init];
    if (self) {
        self.retryInterval = retryInterval;
        self.currentRetryInterval = retryInterval;
        self.maxRetryInterval = maxRetryInterval;
        self.reconnectBlock = block;
        self.queue = queue;
    }
    return self;
}

- (void)schedule {
    __weak typeof(self) weakSelf = self;
    self.timer = [GCDTimer scheduledTimerWithTimeInterval:self.currentRetryInterval
                                                  repeats:NO
                                                    queue:self.queue
                                                    block:^{
                                                        [weakSelf reconnect];
                                                    }];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)resetRetryInterval {
    self.currentRetryInterval = self.retryInterval;
}

- (void)reconnect {
    [self stop];
    if (self.currentRetryInterval < self.maxRetryInterval) {
        self.currentRetryInterval *= 2;
    }
    self.reconnectBlock();
}

@end
