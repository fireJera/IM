//
//  CTMSGPushProfile.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageLib/CTMSGEnumDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGPushProfile : NSObject

//是否显示远程推送的内容
@property(nonatomic, assign, readonly) BOOL isShowPushContent;

/**
 设置是否显示远程推送的内容
 
 @param isShowPushContent 是否显示推送的具体内容（ YES显示 NO 不显示）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 */
- (void)updateShowPushContentStatus:(BOOL)isShowPushContent
                            success:(void (^)(void))successBlock
                              error:(void (^)(CTMSGErrorCode status))errorBlock;

@end

NS_ASSUME_NONNULL_END
