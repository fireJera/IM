//
//  CTMSGPhotoResultModel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, CTMSGPhotoResultModelMediaType) {
    CTMSGPhotoResultModelMediaTypePhoto = 0,   // 照片
    CTMSGPhotoResultModelMediaTypeVideo        // 视频
};

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGPhotoResultModel : NSObject

/**  标记  */
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger photoIndex;
@property (nonatomic, assign) NSInteger videoIndex;

/**  资源类型  */
@property (nonatomic, assign) CTMSGPhotoResultModelMediaType mediaType;

/**  原图URL  */
@property (nonatomic, strong) NSURL *fullSizeImageURL;

/**  原尺寸image 如果资源为视频时此字段为视频封面图片  */
@property (nonatomic, strong) UIImage *displaySizeImage;

/**  原图方向  */
@property (nonatomic, assign) int fullSizeImageOrientation;

/**  视频Asset  */
@property (nonatomic, strong) AVAsset *avAsset;

/**  视频URL  */
@property (nonatomic, strong) NSURL *videoURL;

/**  创建日期  */
@property (nonatomic, strong) NSDate *creationDate;

/**  位置信息  */
@property (nonatomic, strong) CLLocation *location;


@end

NS_ASSUME_NONNULL_END
