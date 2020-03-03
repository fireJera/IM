//
//  CTMSGUploadMediaStatusListener.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUploadMediaStatusListener.h"

@implementation CTMSGUploadMediaStatusListener

- (instancetype)initWithMessage:(CTMSGMessage *)message
                 uploadProgress:(void (^)(int))progressBlock
                  uploadSuccess:(nonnull void (^)(CTMSGMessageContent * _Nonnull, long, NSDictionary *))successBlock
                    uploadError:(void (^)(CTMSGErrorCode))errorBlock
                   uploadCancel:(void (^)(void))cancelBlock {
    self = [super init];
    if (!self) return nil;
    if (!message) return nil;
    _currentMessage = message;
    _updateBlock = progressBlock;
    _successBlock = successBlock;
    _errorBlock = errorBlock;
    _cancelBlock = cancelBlock;
    return self;
}

- (void)cancelUpload {
    
}

@end
