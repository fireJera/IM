//
//  CTMSGAMRDataConverter.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CTMSGAMRDataConverter : NSObject

///*!
// 获取AMR格式与WAV格式音频转换工具类单例
// 
// @return AMR格式与WAV格式音频转换工具类单例
// */
//+ (instancetype)sharedAMRDataConverter;
//
///*!
// 将AMR格式的音频数据转化为WAV格式的音频数据
// 
// @param data    AMR格式的音频数据，必须是AMR-NB的格式
// @return        WAV格式的音频数据
// */
//- (NSData *)decodeAMRToWAVE:(NSData *)data NS_UNAVAILABLE;
//
//- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data NS_UNAVAILABLE;
//
///*!
// 将WAV格式的音频数据转化为AMR格式的音频数据（8KHz采样）
// 
// @param data            WAV格式的音频数据
// @param nChannels       声道数
// @param nBitsPerSample  采样位数（精度）
// @return                AMR-NB格式的音频数据
// 
// @discussion
// 此方法为工具类方法，您可以使用此方法将任意WAV音频转换为AMR-NB格式的音频。
// 
// @warning
// 如果您想和SDK自带的语音消息保持一致和互通，考虑到跨平台和传输的原因，SDK对于WAV音频有所限制.
// 具体可以参考RCVoiceMessage中的音频参数说明(nChannels为1，nBitsPerSample为16)。
// */
//- (NSData *)encodeWAVEToAMR:(NSData *)data channel:(int)nChannels nBitsPerSample:(int)nBitsPerSample NS_UNAVAILABLE;
//
///**
// *  转换wav到amr
// *
// *  @param aWavPath  wav文件路径
// *  @param aSavePath amr保存路径
// *
// *  @return 0失败 1成功
// */
//- (int)convertWavToAmr:(NSString *)aWavPath amrSavePath:(NSString *)aSavePath;
//
///**
// *  转换amr到wav
// *
// *  @param aAmrPath  amr文件路径
// *  @param aSavePath wav保存路径
// *
// *  @return 0失败 1成功
// */
//- (int)convertAmrToWav:(NSString *)aAmrPath wavSavePath:(NSString *)aSavePath;

@end
