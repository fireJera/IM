//
//  CTMSGAlbumManager.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class CTMSGAlbumModel, CTMSGPhotoModel;

typedef NS_ENUM(NSUInteger, CTMSGAlbumListSelectionType) {
    CTMSGAlbumListSelectionTypePhoto,
    CTMSGAlbumListSelectionTypeVideo,
    CTMSGAlbumListSelectionTypeAll,
};

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGAlbumManager : NSObject

//////////////
//  选择前配置的选项
//////////////
/**
 每行多少个
 */
@property (nonatomic, assign) NSInteger columnCount;

/**
 时间排序， 默认 = yes
 */
@property (nonatomic, assign) BOOL reverseDate;

/**
 默认 all
 */
@property (nonatomic, assign) CTMSGAlbumListSelectionType selectionType;

/**
 第一张是否在头部 yes - header no footer default yes
 */
@property (assign, nonatomic) BOOL firstTop;

/**
 *  是否缓存相册, manager会监听系统相册变化(需要此功能时请不要关闭监听系统相册功能)   默认YES
 */
@property (assign, nonatomic) BOOL cacheAlbum;

/**
 *  是否监听系统相册  -  如果开启了缓存相册 自动开启监听   默认 YES
 */
@property (assign, nonatomic) BOOL monitorSystemAlbum;

/**
 在列表中展示GIF 默认 yes
 */
@property (nonatomic, assign) BOOL showGif;

/**
 在列表中展示Live图 默认 yes
 */
@property (nonatomic, assign) BOOL showLive;

@property (assign, nonatomic, readonly) BOOL singleSelected;

// NO
@property (assign, nonatomic, readonly) BOOL singleSelectedClip;
/**
 最大选择数量 默认9
 */
@property (nonatomic, assign) NSInteger maxNum;

/**
 最大图片选择数量 默认9
 */
@property (nonatomic, assign) NSInteger maxPhotoNum;

/**
 最大视频选择数量 默认1
 */
@property (nonatomic, assign) NSInteger maxVideoNum;

/**
 最长视频时间 默认 max_float
 */
@property (nonatomic, assign) NSInteger maxVideoDuration;

/**
 最短视频时间 默认 0 无限制
 */
@property (nonatomic, assign) NSInteger minVideoDuration;

/**
 最大图片大小 (size)默认 CGSizeZero = CGSizeMax
 */
@property (nonatomic, assign) CGSize maxPhotoSize;

/**
 最小图片大小 (size)默认 CGSizeZero
 */
@property (nonatomic, assign) CGSize minPhotoSize;
/**
 是否在获取结果中使用压缩 默认 NO
 */
@property (nonatomic, assign) BOOL shouldCompress;

/**
 压缩质量 0-1 默认 1
 */
@property (nonatomic, assign) NSInteger quality;

/**
 是否可以打开相机 默认 NO
 */
@property (nonatomic, assign) BOOL showCamera;

/**
 是否保存照片到相机 默认 YES
 */
@property (nonatomic, assign) BOOL saveCameraPhotoToAlbum;

/**
 collectionViewCell 要用到的icon
 */
@property (nonatomic, strong) NSDictionary<NSString *, UIImage *> *albumListCellIcon;

/**  系统相册发生了变化  */
@property (nonatomic, copy) void (^photoLibraryDidChangeWithPhotoViewController)(NSArray *collectionChanges);
@property (nonatomic, copy) void (^photoLibraryDidChangeWithPhotoPreviewViewController)(NSArray *collectionChanges);
@property (nonatomic, copy) void (^photoLibraryDidChangeWithVideoViewController)(NSArray *collectionChanges);
@property (nonatomic, copy) void (^photoLibraryDidChangeWithPhotoView)(NSArray *collectionChanges ,BOOL selectPhoto);

//////////////
//  完成选择之后获取的内容
//////////////

/**
 意义不明 猜测是将要存储的相册 相机胶卷 || 所有照片
 */
@property (nonatomic, strong) CTMSGAlbumModel * albumModel;

/**
 选择后的数组
 */
@property (nonatomic, strong) NSMutableArray<CTMSGPhotoModel *> * selectedList;

///**
// 选择后的照片数组
// */
//@property (nonatomic, strong) NSMutableArray * _Nullable selectedPhotos;
//
///**
// 选择后的视频数组
// */
//@property (nonatomic, strong) NSMutableArray * _Nullable selectedVideos;

///**
// 裁剪后的照片
// */
//@property (nonatomic, strong) UIImage * _Nullable selectedImage;
///**
// 裁剪前的原照
// */
//@property (nonatomic, strong) UIImage * _Nullable selectedOriginImage;
//
///**
// 裁剪后的照片的上传的路径
// */
//@property (nonatomic, copy) NSString * _Nullable uploadPath;
///**
// 裁剪后的原照的上传的路径
// */
//@property (nonatomic, copy) NSString * _Nullable uploadOriginPath;

/**
 所有相册
 */
@property (nonatomic, strong, readonly) NSArray<CTMSGAlbumModel *> *albums;

/**
 是否正在选择照片
 */
@property (nonatomic, assign) BOOL selecting;

/**
 初始化方法
 
 @param selectionType <#selectionType description#>
 @return <#return value description#>
 */
- (instancetype)initWithSelectionType:(CTMSGAlbumListSelectionType)selectionType;

- (void)fetchAllAlbum:(void(^)(NSArray<CTMSGAlbumModel *> *albums))albums;

/**
 获取全部相册 (只是相册 不包含图片)
 
 @param albums <#albums description#>
 */
- (void)fetchAllAlbum:(void(^)(NSArray<CTMSGAlbumModel *> *albums))albums showSelectTag:(BOOL)showSelectTag;

/**
 获取所有相册 (只是相册 不包含图片)
 
 @param firstAlbum 拿到第一个相册后回调一次
 @param albums 所有相册的回调
 @param onlyFirst 是否只需获取 相机胶卷或所有照片
 */
- (void)getAllAlbums:(void(^)(CTMSGAlbumModel *firstAlbum))firstAlbum albums:(void(^)(NSArray<CTMSGAlbumModel *> *albums))albums onlyFirst:(BOOL)onlyFirst;


- (void)fetchPhotoForPHFetchResult:(PHFetchResult *)result
                        limitCount:(NSInteger)limitCount
                             index:(NSInteger)index
                            result:(void(^)(NSArray<CTMSGPhotoModel *> * photos, NSArray<CTMSGPhotoModel *> * videos, NSArray<CTMSGPhotoModel *> * objs))list;
/**
 获取相册中的照片
 
 @param result <#result description#>
 @param index <#index description#>
 @param list <#list description#>
 */
- (void)fetchAllPhotoForPHFetchResult:(PHFetchResult *)result index:(NSInteger)index result:(void(^)(NSArray<CTMSGPhotoModel *> * photos, NSArray<CTMSGPhotoModel *> * videos, NSArray<CTMSGPhotoModel *> * objs))list;


- (void)getAllPhotoForAlbum:(CTMSGAlbumModel *)albumModel complete:(void (^)(NSArray<CTMSGPhotoModel *> *allList, NSArray<CTMSGPhotoModel *> *previewList, NSArray<CTMSGPhotoModel *> *photoList, NSArray<CTMSGPhotoModel *> *videoList, CTMSGPhotoModel *firstSelectModel))complete;

/**
 删除所有选中的照片
 */
- (void)clearSelectedList NS_UNAVAILABLE;

/**
 生成Cell用于展示照片属性的Icon Image
 */
- (void)getCellIcons;

@end

NS_ASSUME_NONNULL_END
