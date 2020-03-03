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

@interface CTMSGAudioRecordTool : NSObject

@property (nonatomic, assign, readonly) BOOL recording;
@property (nonatomic, copy, readonly) NSString * audioRecordPath;
@property (nonatomic, copy, readonly) NSURL * audioRecordUrl;
@property (nonatomic, copy, readonly) NSString * audioRecordCompressPath;

@property (nonatomic, copy, readonly) NSString * playAMRPath;
@property (nonatomic, copy, readonly) NSString * playWAVPath;

+ (instancetype)shareRecorder;

// 这些方法会做好recording 处理 无需判断
- (void)startRecord;
- (void)stopRecord;
- (void)pauseRecord;
- (void)resumeRecord;
- (void)cancelRecord;

- (void)play;
- (void)pausePlay NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
