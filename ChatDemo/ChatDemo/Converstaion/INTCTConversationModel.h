//
//  INTCTConversationModel.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface INTCTChatDetailUser : NSObject

@property (nonatomic, copy) NSString * userid;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, assign) NSInteger age;
//@property (nonatomic, copy) NSString * career;
//@property (nonatomic, copy) NSString * address;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * photo;
@property (nonatomic, assign) BOOL hasWechat;
@property (nonatomic, assign) BOOL videoAuth;
//@property (nonatomic, assign) BOOL isVip;
@property (nonatomic, assign) BOOL isBlack;

@end

@interface INTCTChatDetailMsg : NSObject

@property (nonatomic, copy) NSString * userid;     // 自己uid
@property (nonatomic, copy) NSString * toUserid;   // 对方 targetuid
@property (nonatomic, copy) NSString * sendUserid; // 发送者Uid
@property (nonatomic, copy) NSString * msgUid;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * msgTime;
@property (nonatomic, assign) long long sendTime;
@property (nonatomic, copy) NSString * txt;
@property (nonatomic, copy) NSString * imgUrl;
@property (nonatomic, copy) NSString * imgBigUrl;
@property (nonatomic, copy) NSString * videoCoverUrl;
@property (nonatomic, copy) NSString * videoUrl;
@property (nonatomic, copy) NSString * voiceUrl;
@property (nonatomic, copy) NSString * voiceDuration;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

@end

@interface INTCTConversationModel : NSObject

@property (nonatomic, strong) INTCTChatDetailUser * user;
//@property (nonatomic, strong) NSArray<INTCTAlbum *> * albums;
@property (nonatomic, strong) NSArray<INTCTChatDetailMsg *> * messages;
@property (nonatomic, strong) NSArray<NSString *> * quickTexts;
@property (nonatomic, copy) NSString * matchNote;
//@property (nonatomic, assign) NSInteger isLock;
//@property (nonatomic, copy) NSString * messageLockNote;
//@property (nonatomic, copy) NSString * bottomLockNote;
//@property (nonatomic, copy) NSString * lockURL;
//@property (nonatomic, copy) NSString * lockAlertText;
//@property (nonatomic, copy) NSDictionary * lockParameters;
//@property (nonatomic, copy) NSString * videoUnauthNote;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL favored;
@property (nonatomic, copy) NSString * _Nullable lastId;
@property (nonatomic, copy) NSDictionary * ossConfig;
@property (nonatomic, copy) NSDictionary * reportRequest;
@property (nonatomic, copy) NSString * needSendMsg;

@end

NS_ASSUME_NONNULL_END
