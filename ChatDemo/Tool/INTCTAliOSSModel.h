//
//  INTCTAliOSSModel.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface INTCTAliOSSModel : NSObject

@property (nonatomic, copy) NSString * bucketName;
@property (nonatomic, copy) NSString * endPoint;
@property (nonatomic, copy) NSString * objectPath;
@property (nonatomic, copy) NSString * stsUrl;

@property (nonatomic, copy) NSString * accessKeyId;
@property (nonatomic, copy) NSString * accessKeySecret;
@property (nonatomic, copy) NSString * expiration;
@property (nonatomic, copy) NSString * securityToken;

@property (nonatomic, copy) NSDictionary * callbackParam;
@property (nonatomic, copy) NSDictionary * callbackVar;

//自定义 临时用
@property (nonatomic, copy)     NSString * fileType;                //文件类型
@property (nonatomic, copy)     NSString * fileTypeVar;             //自定义回调参数
@property (nonatomic, assign)   BOOL needAppendOrigin;              //上传头像时是否需要在原图文件名加上后缀
/*
 上传视频时 video cover gif统统为video
 图片时 为 photo
 */
@property (nonatomic, copy) NSString * uploadType;

@end

NS_ASSUME_NONNULL_END
