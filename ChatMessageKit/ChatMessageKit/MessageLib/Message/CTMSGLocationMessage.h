//
//  CTMSGLocationMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 地理位置消息的类型名
 */
extern NSString * const CTMSGLocationMessageTypeIdentifier;

/*!
 地理位置消息类
 
 @discussion 地理位置消息类，此消息会进行存储并计入未读消息数。
 */

@interface CTMSGLocationMessage : CTMSGMessageContent <NSCoding>

/*!
 地理位置的二维坐标
 */
@property(nonatomic, assign) CLLocationCoordinate2D location;

/*!
 地理位置的名称
 */
@property(nonatomic, strong) NSString *locationName;

/*!
 地理位置的缩略图
 */
@property(nonatomic, strong) UIImage *thumbnailImage;

/*!
 地理位置的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化地理位置消息
 
 @param image 地理位置的缩略图
 @param location 地理位置的二维坐标
 @param locationName 地理位置的名称
 @return 地理位置消息的对象
 */
+ (instancetype)messageWithLocationImage:(UIImage *)image
                                location:(CLLocationCoordinate2D)location
                            locationName:(NSString *)locationName;


@end

NS_ASSUME_NONNULL_END
