//
//  CTMSGAudioRecordTool.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/8.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const audioRecordPath;
extern NSString * const audioRecordCompressPath;

// https://www.jianshu.com/p/de221b2bce8e
// https://blog.csdn.net/sharmir/article/details/50553686
@interface CTMSGAudioRecordTool : NSObject

@property (readonly) BOOL recording;
// call befor stop record or current time = 0
@property (readonly) float currentTime;
@property (nonatomic, copy, readonly) NSString * audioRecordPath;
@property (nonatomic, copy, readonly) NSURL * audioRecordUrl;

//@property (nonatomic, copy, readonly) NSString * audioRecordCompressPath;
//@property (nonatomic, copy, readonly) NSString * playAMRPath;
//@property (nonatomic, copy, readonly) NSString * playWAVPath;

@property (nonatomic, copy) void(^playFinishBlock)(void);
@property (nonatomic, copy) void(^recordFinishBlock)(void);

+ (instancetype)shareRecorder;

// 这些方法会做好recording 处理 无需判断
- (BOOL)startRecord;
- (void)stopRecord;
- (void)pauseRecord;
- (void)resumeRecord;
- (void)cancelRecord;

- (void)play;
- (void)stopPlay;
- (void)pausePlay NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
