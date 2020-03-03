//
//  CTMSGPhotoModel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTMSGPhotoModelMediaType) {
    CTMSGPhotoModelMediaTypePhoto = 0,         // 照片
    CTMSGPhotoModelMediaTypeLive,              // LivePhoto
    CTMSGPhotoModelMediaTypeGif,               // gif图
    CTMSGPhotoModelMediaTypeVideo,             // 视频
};

typedef NS_ENUM(NSUInteger, CTMSGPhotoModelMediaSubType) {
    CTMSGPhotoModelMediaSubTypePhoto = 0,      // 照片
    CTMSGPhotoModelMediaSubTypeVideo           // 视频
};

@interface CTMSGPhotoDateModel : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSMutableArray *locationList;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *locationString;
@property (nonatomic, copy) NSArray *photoModelArray;

@end


@interface CTMSGPhotoModel : NSObject

/**
 文件在手机里的原路径(照片 或 视频)
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 视频有值, 照片没有值
 */
@property (nonatomic, strong) NSURL *fileURL;
/**
 创建日期
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 为当前时间([NSDate date])
 */
@property (nonatomic, strong) NSDate *creationDate;
/**
 修改日期
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 为当前时间([NSDate date])
 */
@property (nonatomic, strong) NSDate *modificationDate;
/**
 位置信息 NSData 对象
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 没有值
 */
@property (nonatomic, strong) NSData *locationData;
/**
 位置信息 CLLocation 对象
 
 - 如果是通过相机拍摄的并且没有保存到相册(临时的) 没有值
 */
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, copy) NSString *barTitle;
@property (nonatomic, copy) NSString *barSubTitle;

/**
 照片PHAsset对象
 */
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *localIdentifier;
@property (nonatomic, assign) BOOL isIcloud;
@property (nonatomic, assign) BOOL cloudIsDeletable;
@property (nonatomic, strong) NSURL *fullSizeImageURL;

/**
 视频AVAsset对象
 */
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;

/**
 照片类型
 */
@property (nonatomic, assign) CTMSGPhotoModelMediaType type;
@property (nonatomic, assign) CTMSGPhotoModelMediaSubType subType;

/**
 小图 -- 选中之后有值, 取消选中为空
 */
@property (nonatomic, strong) UIImage * _Nullable thumbPhoto;

/**
 预览照片 -- 选中之后有值, 取消选中为空
 */
@property (nonatomic, strong) UIImage *previewPhoto;

/**
 当前照片所在相册的名称
 */
@property (nonatomic, copy) NSString *albumName;

/**
 请求ID
 */
@property (nonatomic, assign) PHImageRequestID requestID;
@property (nonatomic, assign) PHImageRequestID liveRequestID;


/**
 视频时长
 */
@property (nonatomic, copy) NSString *videoTime;

/**
 选择的下标
 */
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger dateSection;
@property (nonatomic, assign) NSInteger dateItem;
@property (nonatomic, assign) BOOL dateCellIsVisible;

/**
 是否选中
 */
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *selectIndexStr;

/**
 图片宽高
 */
@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) CGSize cacheSize;
/**
 缩小之后的图片宽高
 */
@property (nonatomic, assign) CGSize endImageSize;
@property (nonatomic, assign) CGSize endDateImageSize;
@property (nonatomic, assign) CGSize dateBottomImageSize;

/**
 判断当前照片 是否关闭了livePhoto功能
 */
@property (nonatomic, assign) BOOL isCloseLivePhoto;

/**
 拍照之后的唯一标示
 */
@property (nonatomic, copy) NSString *cameraIdentifier;

/**
 通过相机摄像的视频URL
 */
@property (nonatomic, strong) NSURL *videoURL;

/**
 网络图片的地址
 */
@property (nonatomic, copy) NSString *networkPhotoUrl;

/**
 当前图片所在相册的下标
 */
@property (nonatomic, assign) NSInteger currentAlbumIndex;


/*** 以下属性是使用HXPhotoView时自定义转场动画时所需要的属性 ***/

/**
 选完点下一步之后在collectionView上的图片数组下标
 */
@property (nonatomic, assign) NSInteger endIndex;

@property (nonatomic, assign) NSInteger videoIndex;

/**
 选完点下一步之后在collectionView上的下标
 */
@property (nonatomic, assign) NSInteger endCollectionIndex;

@property (nonatomic, assign) NSInteger fetchOriginalIndex;
@property (nonatomic, assign) NSInteger fetchImageDataIndex;

@property (nonatomic, assign) NSInteger receivedSize;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) BOOL downloadComplete;
@property (nonatomic, assign) BOOL downloadError;

@property (nonatomic, strong) UIImage * _Nullable tempImage;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) CGSize requestSize;                   //意义不明

+ (instancetype)photoModelWithImage:(UIImage *)image NS_UNAVAILABLE;
//+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime;
//+ (instancetype)photoModelWithPHAsset:(PHAsset *)asset;

@property (nonatomic, copy) NSString *fullPathToFile;


@end

NS_ASSUME_NONNULL_END
