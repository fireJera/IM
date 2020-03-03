//
//  CTMSGAudioRecordTool.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/8.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAudioRecordTool.h"
#import <AVFoundation/AVFoundation.h>
#import "CTMSGUtilities.h"
#import "CTMSGIM.h"

@interface CTMSGAudioRecordTool () <AVAudioRecorderDelegate> {
    BOOL _needPlay;
}

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy, readwrite) NSString * audioRecordPath;
@property (nonatomic, copy, readwrite) NSString * audioRecordCompressPath;

@property (nonatomic, copy, readwrite) NSString * playAMRPath;
@property (nonatomic, copy, readwrite) NSString * playWAVPath;
//@property (nonatomic, strong) NSTimer * timer;

@end

@implementation CTMSGAudioRecordTool

+ (instancetype)shareRecorder {
    static CTMSGAudioRecordTool * _tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[self alloc] init];
        [_tool p_ctmsg_commonInit];
    });
    return _tool;
}

- (void)p_ctmsg_commonInit {
//    NSDictionary * setting = @{
////                               AVFormatIDKey: @(kAudioFormatLinearPCM),
//                               AVFormatIDKey: @(kAudioFormatMPEG4AAC),
//                               AVSampleRateKey: [NSNumber numberWithFloat:8000],
//                               AVNumberOfChannelsKey: [NSNumber numberWithInt:2],
//                               AVLinearPCMBitDepthKey : @(8),
//                               AVLinearPCMIsFloatKey: @(YES),
//                               AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMedium],
//                               };
    NSError * error = nil;
    NSURL * url = self.audioRecordUrl;
    NSDictionary *configDic = @{// 编码格式
                                AVFormatIDKey:@(kAudioFormatLinearPCM),
                                // 采样率
                                AVSampleRateKey:@(8000.0),
                                // 通道数
                                AVNumberOfChannelsKey:@(1),
                                AVLinearPCMBitDepthKey: @16,
                                AVLinearPCMIsNonInterleaved: @NO,
                                AVLinearPCMIsFloatKey: @NO,
                                AVLinearPCMIsBigEndianKey: @NO,
                                // 录音质量
                                AVEncoderAudioQualityKey:@(AVAudioQualityMin)
                                };
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                 settings:configDic
                                                    error:&error];
    NSLog(@"Error: %@", [error description]);
    //TODO: - fix this set active no or yes
    if ([CTMSGIM sharedCTMSGIM].isExclusiveSoundPlayer) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    if (error) {
        NSLog(@"创建失败，原因是 = %@", error);
    }
    else {
        NSLog(@"创建成功");
    }
    
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;
    [_audioRecorder prepareToRecord];
    _needPlay = NO;
}

- (void)startTimer {
    [_audioRecorder updateMeters];
//    [self.audioRecorder updateMeters];//更新测量值
//    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
//    CGFloat progress=(1.0/160.0)*(power+160.0);
//    [self.audioPower setProgress:progress];
    
//    float peak0 = ([_audioRecorder peakPowerForChannel:0] + 160.0) * (1.0 / 160.0);
//    float peak1 = ([_audioRecorder peakPowerForChannel:1] + 160.0) * (1.0 / 160.0);
//    float ave0 = ([_audioRecorder averagePowerForChannel:0] + 160.0) * (1.0 / 160.0);
//    float ave1 = ([_audioRecorder averagePowerForChannel:1] + 160.0) * (1.0 / 160.0);
}

#pragma mark - public

- (void)startRecord {
//    static const int kMaxDuration = [CTMSGIM sharedCTMSGIM].maxVoiceDuration;
    [_audioRecorder recordForDuration:[CTMSGIM sharedCTMSGIM].maxVoiceDuration];
}

- (void)stopRecord {
    [_audioRecorder stop];
}

- (void)pauseRecord {
    if (_audioRecorder.recording) {
        [_audioRecorder pause];
    }
}

- (void)resumeRecord {
    if (!_audioRecorder.recording) {
        [_audioRecorder record];
    }
}

- (void)cancelRecord {
    [_audioRecorder stop];
    [_audioRecorder deleteRecording];
}

- (void)play {
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
    _needPlay = YES;
}

- (void)pausePlay {
    [_audioPlayer pause];
}

#pragma mark - delete

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_needPlay) {
        NSError *error = nil;
        NSURL * url = [NSURL fileURLWithPath:self.audioRecordPath];
        //    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:self.audioRecordPath];
//        NSData * data = [NSData dataWithContentsOfFile:self.audioRecordCompressPath];
//        _audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return;
        }
        _needPlay = YES;
    }
}

#pragma mark - getter

- (BOOL)recording {
    return _audioRecorder.recording;
}

- (NSString *)audioRecordPath {
    if (!_audioRecordPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *str1 = NSHomeDirectory();
        NSString * filePath1 = [NSString stringWithFormat:@"%@/Documents/myFile/record/inputVoiceWAV.wav",str1];

//        NSLog(@"%@",filePath1);
        if(![fileManager fileExistsAtPath:filePath1]) { //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
//            NSLog(@"first run");
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *directryPath = [path stringByAppendingPathComponent:@"myFile"];
            directryPath = [directryPath stringByAppendingPathComponent:@"record"];
            [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *filePath = [directryPath stringByAppendingPathComponent:@"inputVoiceWAV.wav"];
//            NSLog(@"%@",filePath);
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
            _audioRecordPath = filePath;
        }
        _audioRecordPath = filePath1;
    }
    return _audioRecordPath;
}

- (NSString *)audioRecordCompressPath {
    if (!_audioRecordCompressPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *str = NSHomeDirectory();
        NSString * filePath = [NSString stringWithFormat:@"%@/Documents/myFile/record/inputVoiceAmr.caf",str];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *directryPath = [path stringByAppendingPathComponent:@"myFile"];
            directryPath = [directryPath stringByAppendingPathComponent:@"record"];
            [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *filePath1 = [directryPath stringByAppendingPathComponent:@"inputVoiceAmr.caf"];
            [fileManager createFileAtPath:filePath1 contents:nil attributes:nil];
            _audioRecordCompressPath = filePath1;
        }
        _audioRecordCompressPath = filePath;
    }
    return _audioRecordCompressPath;
}

- (NSString *)playAMRPath {
    if (!_audioRecordCompressPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *str = NSHomeDirectory();
        NSString * filePath = [NSString stringWithFormat:@"%@/Documents/myFile/record/plaAmr.caf",str];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *directryPath = [path stringByAppendingPathComponent:@"myFile"];
            directryPath = [directryPath stringByAppendingPathComponent:@"record"];
            [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *filePath1 = [directryPath stringByAppendingPathComponent:@"plaAmr.caf"];
            [fileManager createFileAtPath:filePath1 contents:nil attributes:nil];
            _audioRecordCompressPath = filePath1;
        }
        _audioRecordCompressPath = filePath;
    }
    return _audioRecordCompressPath;
}

- (NSString *)playWAVPath {
    if (!_audioRecordCompressPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *str = NSHomeDirectory();
        NSString * filePath = [NSString stringWithFormat:@"%@/Documents/myFile/record/playWav.wav",str];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *directryPath = [path stringByAppendingPathComponent:@"myFile"];
            directryPath = [directryPath stringByAppendingPathComponent:@"record"];
            [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *filePath1 = [directryPath stringByAppendingPathComponent:@"playWav.wav"];
            [fileManager createFileAtPath:filePath1 contents:nil attributes:nil];
            _audioRecordCompressPath = filePath1;
        }
        _audioRecordCompressPath = filePath;
    }
    return _audioRecordCompressPath;
}

- (NSURL *)audioRecordUrl {
    NSURL *url = [NSURL URLWithString:self.audioRecordPath];
//    [NSURL fileURLWithPath:self.audioRecordPath];
    return url;
}

//- (NSTimer *)timer {
//    if (!_timer) {
//        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
//    }
//    return _timer;
//}

@end
