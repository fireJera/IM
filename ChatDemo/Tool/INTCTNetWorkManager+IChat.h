//
//  INTCTNetWorkManager+IChat.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTNetWorkManager.h"

NS_ASSUME_NONNULL_BEGIN

@class INTCTSignGuideModel, INTCTDiscoveryModel, INTCTHomeMatch, INTCTShanYanUser;
@class INTCTUserHomeModel, INTCTAccountModel, INTCTVisitorModel, INTCTMyModel;
@class INTCTInfoEditModel, INTCTConversationListModel, INTCTConversationModel, INTCTSystemModel;
@class INTCTBannerModel;

typedef NS_ENUM(NSUInteger, INTCTInviteType) {
    INTCTInviteTypeWechat,
    INTCTInviteTypeVideoAuth,
    INTCTInviteTypeAlbum,
    INTCTInviteTypeAvatar,
    INTCTInviteTypeNone,
};

typedef NS_ENUM(NSInteger, INTCTNetRequestErrorType) {
    INTCTNetRequestErrorTypeNetDisable = -1000,
    INTCTNetRequestErrorTypeRequestFail = -5000,
};

//extern NSString * const INTCTMineInfoChangeNotification;
extern NSString * const INTCTUserHomeInfoChangeNotification;
extern NSString * const INTCTVideoAuthChangeNotification;

@interface INTCTNetWorkManager (IChat)

+ (void)intct_revoke:(void(^)(BOOL shouldGoLogin))resultBlock;
+ (void)intct_chatToken:(void(^)(id _Nullable result))resultBlock;

+ (void)intct_pushToken:(NSString *)token result:(void(^ _Nullable )(BOOL shouldGoLogin))resultBlock;

// 从微信u获取的refreshtoken
//+ (void)intct_wechatLogin:(void(^)(BOOL loginSuccess))resultBlock;
// 从微信获取的code
//+ (void)intct_wechatCodeLogin:(NSString *)code result:(void(^ _Nullable)(BOOL loginSuccess))resultBlock;

+ (void)intct_phoneLogin:(NSString *)phoneNum pass:(NSString *)pass result:(void(^ _Nullable)(BOOL loginSuccess))resultBlock;

//+ (void)intct_getSmsCode:(NSString *)phoneNum result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;
//
//+ (void)intct_phoneRegister:(NSString *)phoneNum
//                 verifyCode:(NSString *)code
//                       pass:(NSString *)pass
//                   nickname:(NSString *)nickname
//                        sex:(NSInteger)sex
//                     result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;

+ (void)intct_logout:(void (^)(BOOL isSuccess))resultBlock;

+ (void)intct_sendRequest:(NSMutableDictionary *)postData
                  reqData:(NSDictionary *)reqData
                   method:(NSString *)method
             successBlock:(void (^)(BOOL isSuccess, id result))successBlock
             failureBlock:(HttpRequestFailBlock)failureBlock;

//+ (void)intct_signUpTransition:(void (^)(NSError * _Nullable))resultBlock;
//
//+ (void)intct_signUpVideoWithSkip:(BOOL)isSkip result:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;
//
//+ (void)intct_playVideo:(NSString *)targetId result:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;
//
//+ (void)intct_shanYanUser:(void(^ _Nullable)(NSError * _Nullable error, NSArray<INTCTShanYanUser *> * _Nullable users, NSString * _Nullable title))resultBlock;

//首页

//+ (void)intct_matchInfo:(void (^)(NSError * _Nullable, INTCTHomeMatch * _Nullable match))resultBlock;
//+ (void)intct_timeMatch:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;
//+ (void)intct_cancelMatch:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;
//+ (void)intct_exitMatchConversationWithUserId:(NSString *)userId result:(void (^)(NSError * _Nullable))resultBlock;

#pragma mark - discovery

//+ (void)intct_discoveryWithPage:(NSUInteger)page result:(void (^)(NSError * _Nullable error, INTCTDiscoveryModel * _Nullable discovery))resultBlock;
//
//+ (void)intct_bannerInfo:(void (^)(NSError * _Nullable error, INTCTBannerModel * _Nullable banner))resultBlock;

#pragma mark - chat

+ (void)intct_chatListWithLastId:(nullable NSString *)lastId result:(void (^)(NSError * _Nullable error, INTCTConversationListModel * _Nullable chatData))resultBlock;

+ (void)intct_chatDetailWithTargetId:(NSString *)targetId
                              lastId:(NSString *)lastId
                             isMatch:(BOOL)isMatch
                              result:(void (^)(NSError * _Nullable error, INTCTConversationModel * _Nullable chatDetail))resultBlock;

+ (void)intct_matchFollow:(nullable NSString *)userid
              result:(void (^ _Nullable)(NSError * _Nullable error, BOOL followed))resultBlock;

+ (void)intct_msgUnlock:(NSString *)targetId result:(void (^)(NSError * _Nullable error, NSDictionary * _Nullable resultDic))resultBlock;

+ (void)readMessageInChatDetail:(NSString *)targetId result:(void (^)(NSError * _Nullable error))resultBlock;
+ (void)deleteMessageWithTargetId:(NSString *)targetId msgUid:(NSString *)msgUid result:(void (^)(NSError * _Nullable error))resultBlock;

+ (void)intct_removeConversationWithTargetId:(NSString *)targetId result:(void (^)(NSError * _Nullable error))resultBlock;

// 个人中心
//+ (void)intct_myCenter:(void (^ _Nullable)(BOOL isSuccess, INTCTMyModel * _Nullable my))resultBlock;
//+ (void)intct_chatHelloToUserId:(NSString *)userId result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;
//
//+ (void)intct_myHomeInfo:(nullable NSString *)userid
//                  result:(void (^ _Nullable)(BOOL isSuccess, INTCTUserHomeModel * _Nullable homeModel))resultBlock;
//
//+ (void)intct_follow:(nullable NSString *)userid
//              result:(void (^ _Nullable)(NSError * _Nullable error, NSUInteger followStatus))resultBlock;
//
//+ (void)intct_invite:(nullable NSString *)userid
//            invitype:(INTCTInviteType)inviteType
//              result:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;

//+ (void)intct_myInfoEditWithParameters:(NSDictionary *)dic result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;

//+ (void)intct_myEditInfo:(void (^ _Nullable)(BOOL isSuccess, INTCTInfoEditModel * _Nullable editInfo))resultBlock;

//+ (void)intct_myAccount:(void (^ _Nullable)(BOOL isSuccess, INTCTAccountModel * _Nullable account))resultBlock;

//+ (void)intct_myWechatInfo:(void (^ _Nullable)(BOOL isSuccess, NSDictionary * _Nullable wechatDic))resultBlock;

//+ (void)intct_myVideoAuthInfo:(void (^ _Nullable)(BOOL isSuccess, NSDictionary * _Nullable videoDic))resultBlock;

//+ (void)intct_blackWithUserId:(NSString *)userId result:(void (^ _Nullable)(NSError * _Nullable error, NSDictionary * _Nullable result))resultBlock;;

//+ (void)intct_delPhotoWithPhotoId:(NSString *)photoId result:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * result))resultBlock;

//+ (void)intct_visitorListWithURL:(NSString *)URL lastId:(NSString *)lastId result:(void (^ _Nullable)(BOOL isSuccess, INTCTVisitorModel * _Nullable visitor))resultBlock;

//+ (void)intct_exchangPropsType:(NSString *)type
//                           num:(NSInteger)num
//                        result:(void (^ _Nullable)(NSError * _Nullable error, NSInteger afterNum, NSInteger afterGold))resultBlock;

//+ (void)intct_accountVipInfo:(void (^ _Nullable)(BOOL isSuccess, INTCTMemberModel * _Nullable member))resultBlock;

//+ (void)intct_myHomeBgList:(NSString *)lastId :(void (^ _Nullable)(NSError * _Nullable error, INTCTHomeBgImage * _Nullable homeImage))resultBlock;

//+ (void)intct_iapOrderInfo:(NSString *)productId
//                      type:(NSInteger)type
//                    result:(void (^ _Nullable)(NSError * _Nullable error, NSString * _Nullable proid, NSString * _Nullable orderId))resultBlock;
//
//+ (void)intct_iapReceiptOrderId:(NSString *)orderId
//                        receipt:(NSString *)receipt
//                  transactionId:(NSString *)transactionId
//                         result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;
//
//+ (void)intct_notificationList:(NSString *)lastId result:(void (^ _Nullable)(NSError * _Nullable error, INTCTSystemModel * _Nullable sysModel))resultBlock;

//+ (void)intct_removeNotificatin:(NSString *)notifyId result:(void (^ _Nullable)(BOOL isSuccess))resultBlock;
//
//+ (void)intct_clearNotification:(void (^ _Nullable)(NSError * _Nullable error))resultBlock;

@end

NS_ASSUME_NONNULL_END
