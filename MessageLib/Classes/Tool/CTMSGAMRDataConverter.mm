//
//  CTMSGAMRDataConverter.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAMRDataConverter.h"
#import "amrFileCodec.h"

@implementation CTMSGAMRDataConverter

+ (instancetype)sharedAMRDataConverter {
    static CTMSGAMRDataConverter * _conveter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _conveter = [[super allocWithZone:NULL] init];
    });
    return _conveter;
}

- (NSData *)decodeAMRToWAVE:(NSData *)data {
    return nil;
}

- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data {
    return nil;
}

- (NSData *)encodeWAVEToAMR:(NSData *)data channel:(int)nChannels nBitsPerSample:(int)nBitsPerSample {
    return nil;
}

//转换amr到wav
- (int)convertAmrToWav:(NSString *)aAmrPath wavSavePath:(NSString *)aSavePath {
    if (!DecodeAMRFileToWAVEFile([aAmrPath cStringUsingEncoding:NSASCIIStringEncoding], [aSavePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0;
    return 1;
}

//转换wav到amr
- (int)convertWavToAmr:(NSString *)aWavPath amrSavePath:(NSString *)aSavePath {
    if (!EncodeWAVEFileToAMRFile([aWavPath cStringUsingEncoding:NSASCIIStringEncoding], [aSavePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    return 1;
}

@end
