//
//  CTMSGAlbumTool.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class CTMSGPhotoModel, CTMSGAlbumManager, PhotoResultModel, CTMSGAlbumModel;

#ifdef DEBUG
#define NSSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else
#define NSSLog(...)
#endif

#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define kNavigationBarHeight (kDevice_Is_iPhoneX ? 88 : 64)
#define kTopMargin (kDevice_Is_iPhoneX ? 24 : 0)
#define kBottomMargin (kDevice_Is_iPhoneX ? 34 : 0)

#define iOS11_Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)

#define iOS9_Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1_Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS8_2Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.2f)


NS_ASSUME_NONNULL_BEGIN

@interface CTMSGAlbumTool : NSObject

/**
 超过最大数 提示文案
 
 @param model 点击的cell
 @param viewmodel viewmodel
 @return 返回的提示文案
 */
+ (NSString *)maximumOfJudgment:(CTMSGPhotoModel *)model
                      viewmodel:(CTMSGAlbumManager *)viewmodel;
//
+ (UIImage *)imageNamed:(NSString *)imageName;

//+ (void)saveImageToAlbum:(UIImage *)image completion:(void(^)(void))completion error:(void (^)(void))error;
//+ (void)saveVideoToAlbum:(NSURL *)videoUrl completion:(void(^)(void))completion error:(void (^)(void))error;

/**
 将选择的模型数组写入临时目录
 
 @param selectList 已选的模型数组
 @param completion 成功block
 @param error 失败block
 */
//+ (void)selectListWriteToTempPath:(NSArray *)selectList requestList:(void (^)(NSArray *imageRequestIds, NSArray *videoSessions))requestList completion:(void (^)(NSArray<NSURL *> *allUrl, NSArray<NSURL *> *imageUrls, NSArray<NSURL *> *videoUrls))completion error:(void (^)())error;

/**
 根据PHAsset对象获取照片信息   此方法会回调多次
 */
+ (PHImageRequestID)getPhotoForPHAsset:(PHAsset *)asset
                                  size:(CGSize)size
                            completion:(void(^)(UIImage *image, NSDictionary *info))completion;

///**
// 根据PHAsset对象获取照片信息   此方法只会回调一次
// */
//+ (PHImageRequestID)getHighQualityFormatPhotoForPHAsset:(PHAsset *)asset
//                                                   size:(CGSize)size
//                                             completion:(void(^)(UIImage *image,NSDictionary *info))completion
//                                                  error:(void(^)(NSDictionary *info))error;
//
//
///**
// 根据CTMSGPhotoModel模型获取照片原图路径
//
// @param model 照片模型
// @param complete 原图url
// */
//+ (void)getFullSizeImageUrlFor:(CTMSGPhotoModel *)model
//                      complete:(void (^)(NSURL *url))complete;

/**
 将CTMSGPhotoModel模型数组转化成PhotoResultModel模型数组  - 已按选择顺序排序
 !!!!  必须是全部类型的那个数组  !!!!
 
 /--  不推荐使用此方法,请使用一键写入临时目录的方法  --/
 位置信息 创建日期 已加入CTMSGPhotoModel里选完之后就可拿到
 
 @param selectedList 已选的所有类型(photoAndVideo)数组
 @param complete 各个类型PhotoResultModel模型数组
 */
//+ (void)getSelectedListResultModel:(NSArray<CTMSGPhotoModel *> *)selectedList complete:(void (^)(NSArray<PhotoResultModel *> *alls, NSArray<PhotoResultModel *> *photos, NSArray<PhotoResultModel *> *videos))complete;

/**
 获取已选照片模型数组里照片原图路径  - 已按选择顺序排序
 
 @param photos 已选照片模型数组
 @param complete 原图路径数组
 */
//+ (void)getSelectedPhotosFullSizeImageUrl:(NSArray<CTMSGPhotoModel *> *)photos
//                                 complete:(void (^)(NSArray<NSURL *> *imageUrls))complete;

/**
 根据已选照片数组返回 原图/高清(质量略小于原图) 图片数组   - 已按选择顺序排序
 
 注: 此方法只是一个简单的取image,有可能跟你的需求不一样.那么你就需要自己重新循环模型数组取数据了
 
 @param photos 选中照片数组
 @param completion image数组
 */
//+ (void)getImageForSelectedPhoto:(NSArray<CTMSGPhotoModel *> *)photos type:(HXPhotoToolsFetchType)type completion:(void(^)(NSArray<UIImage *> *images))completion;

//+ (void)isICloudAssetWithModel:(CTMSGPhotoModel *)model
//                      complete:(void (^)(BOOL isICloud))complete;
//
+ (PHImageRequestID)getImageWithModel:(CTMSGPhotoModel *)model
                           completion:(void (^)(UIImage *image, CTMSGPhotoModel *model))completion;
//
//+ (PHImageRequestID)getImageWithAlbumModel:(CTMSGAlbumModel *)model
//                                      size:(CGSize)size
//                                completion:(void (^)(UIImage *image, CTMSGAlbumModel *model))completion;
//
+ (PHImageRequestID)getPlayerItemWithPHAsset:(PHAsset *)asset
                          startRequestIcloud:(void(^)(PHImageRequestID cloudRequestId))startRequestIcloud
                             progressHandler:(void(^)(double progress))progressHandler
                                  completion:(void(^)(AVPlayerItem *playerItem))completion
                                      failed:(void(^)(NSDictionary *info))failed;

//+ (PHImageRequestID)getAVAssetWithPHAsset:(PHAsset *)asset
//                       startRequestIcloud:(void(^)(PHImageRequestID cloudRequestId))startRequestIcloud
//                          progressHandler:(void(^)(double progress))progressHandler
//                               completion:(void(^)(AVAsset *asset))completion
//                                   failed:(void(^)(NSDictionary *info))failed;

//+ (PHImageRequestID)getHighQualityFormatPhoto:(PHAsset *)asset size:(CGSize)size succeed:(void (^)(UIImage *image))succeed failed:(void(^)())failed;

+ (PHImageRequestID)getHighQualityFormatPhoto:(PHAsset *)asset
                                         size:(CGSize)size
                           startRequestIcloud:(void(^)(PHImageRequestID cloudRequestId))startRequestIcloud
                              progressHandler:(void(^)(double progress))progressHandler
                                   completion:(void(^)(UIImage *image))completion
                                       failed:(void(^)(NSDictionary *info))failed;

+ (PHImageRequestID)getImageData:(PHAsset *)asset
              startRequestIcloud:(void(^)(PHImageRequestID cloudRequestId))startRequestIcloud
                 progressHandler:(void(^)(double progress))progressHandler
                      completion:(void(^)(NSData *imageData, UIImageOrientation orientation))completion
                          failed:(void(^)(NSDictionary *info))failed;

/**
 获取视频的时长 视频时长秒数 转换成 时:分:秒
 */
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;

/**
 相册名称转换 为中文
 */
+ (NSString *)transFormPhotoTitle:(NSString *)englishName;

///**
// 根据PHAsset对象获取照片信息
// */
//+ (int32_t)fetchPhotoWithAsset:(id)asset
//                     photoSize:(CGSize)photoSize
//                    completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;
//
/**
 根据PHAsset对象获取LivePhoto
 */
+ (PHImageRequestID)fetchLivePhotoForPHAsset:(PHAsset *)asset
                                        size:(CGSize)size
                                  completion:(void(^)(PHLivePhoto *livePhoto, NSDictionary *info))completion API_AVAILABLE(ios(9.1));

///**
// 获取图片NSData
//
// @param asset 图片对象
// @param completion 返回结果
// */
//+ (PHImageRequestID)fetchPhotoDataForPHAsset:(PHAsset *)asset
//                                  completion:(void(^)(NSData *imageData, NSDictionary *info))completion;
//
///**
// 获取数组里面图片的大小
// */
//+ (void)fetchPhotosBytes:(NSArray *)photos
//              completion:(void(^)(NSString *totalBytes))completion;

/**
 获取指定字符串的宽度
 
 @param text 需要计算的字符串
 @param height 高度大小
 @param fontSize 字体大小
 @return 宽度大小
 */
+ (CGFloat)getTextWidth:(NSString *)text
                 height:(CGFloat)height
               fontSize:(CGFloat)fontSize;

+ (CGFloat)getTextHeight:(NSString *)text
                   width:(CGFloat)width
                fontSize:(CGFloat)fontSize;

///**
// 根据PHAsset对象获取照片信息 带返回错误的block
//
// @param asset 照片的PHAsset对象
// @param size 指定请求的大小
// @param deliveryMode 请求模式
// @param completion 完成后的block
// */
//+ (PHImageRequestID)fetchPhotoForPHAsset:(PHAsset *)asset
//                                    size:(CGSize)size
//                            deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode
//                              completion:(void (^)(UIImage *, NSDictionary *))completion;

@end

NS_ASSUME_NONNULL_END
