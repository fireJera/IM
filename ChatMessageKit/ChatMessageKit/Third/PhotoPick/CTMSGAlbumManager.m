//
//  CTMSGAlbumManager.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAlbumManager.h"
#import "CTMSGAlbumModel.h"
#import <mach/mach_time.h>
#import "CTMSGAlbumTool.h"
#import "CTMSGPhotoModel.h"

@interface CTMSGAlbumManager () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray * allPhotos;
@property (nonatomic, strong) NSMutableArray * allVideos;
@property (nonatomic, strong) NSMutableArray * allObjs;
@property (nonatomic, strong) NSMutableArray * innerAlbums;

@end

@implementation CTMSGAlbumManager

- (instancetype)initWithSelectionType:(CTMSGAlbumListSelectionType)selectionType {
    self = [super init];
    if (!self) return nil;
    [self p_init];
    _selectionType = selectionType;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self p_init];
    return self;
}

- (void)p_init {
    _selectionType = AlbumListSelectionTypeAll;
    _columnCount = 3;
    _reverseDate = YES;
    _scrollDirection = AlbumListScrollDirectionUp;
    _singleSelected = NO;
    _singleSelected = YES;
    _showGif = YES;
    _showLive = YES;
    _maxNum = 9;
    _maxPhotoNum = 9;
    _maxVideoNum = 1;
    _shouldCompress = NO;
    _quality = 1;
    _compressPNG = NO;
    //    _showCamera = NO;
    _selectedList = [NSMutableArray array];
    _selectedPhotos = [NSMutableArray array];
    _selectedVideos = [NSMutableArray array];
    _innerAlbums = [NSMutableArray array];
    _allObjs = [NSMutableArray array];
    _allVideos = [NSMutableArray array];
    _minPhotoSize = CGSizeZero;
    _maxPhotoSize = CGSizeZero;
    _maxVideoDuration = NSIntegerMax;
    _minVideoDuration = 0;
    _saveCameraPhotoToAlbum = YES;
    _showBottomView = NO;
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

#pragma mark - setter

- (void)setSaveCameraPhotoToAlbum:(BOOL)saveCameraPhotoToAlbum {
    _saveCameraPhotoToAlbum = saveCameraPhotoToAlbum;
    if (saveCameraPhotoToAlbum) [self p_getAlbumToSaveCameraPhoto];
}

//- (void)setLocalImages:(NSArray<UIImage *> *)localImages {
//    _localImages = localImages;
//    if (localImages.count > 0) {
//        NSAssert([localImages.firstObject isKindOfClass:[UIImage class]], @"NSArray isn't UIImage array");
//    }
//    dispatch_apply(localImages.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
//        UIImage * image = localImages[index];
//        CTMSGPhotoModel * photo = [CTMSGPhotoModel photoModelWithImage:image];
//        photo.selected = YES;
//
//    });
//}

#pragma mark - public func

- (void)getCellIcons {
    if (!self.singleSelected && !self.albumListCellIcon) {
        self.albumListCellIcon = @{
                                   @"videoIcon" : [CTMSGAlbumTool imageNamed:@"VideoSendIcon@2x.png"] ,
                                   @"gifIcon" : [CTMSGAlbumTool imageNamed:@"timeline_image_gif@2x.png"] ,
                                   @"liveIcon" : [CTMSGAlbumTool imageNamed:@"compose_live_photo_open_only_icon@2x.png"] ,
                                   @"liveBtnImageNormal" : [CTMSGAlbumTool imageNamed:@"compose_live_photo_open_icon@2x.png"] ,
                                   @"liveBtnImageSelected" : [CTMSGAlbumTool imageNamed:@"compose_live_photo_close_icon@2x.png"] ,
                                   @"liveBtnBackgroundImage" : [CTMSGAlbumTool imageNamed:@"compose_live_photo_background@2x.png"] ,
                                   @"selectBtnNormal" : [CTMSGAlbumTool imageNamed:@"compose_guide_check_box_default@2x.png"] ,
                                   @"selectBtnSelected" : [CTMSGAlbumTool imageNamed:@"compose_guide_check_box_right@2x.png"] ,
                                   @"icloudIcon" : [CTMSGAlbumTool imageNamed:@"icon_yunxiazai@2x.png"],
                                   };
    }
}

- (void)fetchAllAlbum:(void (^)(NSArray<CTMSGAlbumModel *> * _Nonnull))albums {
    if (self.innerAlbums.count > 0) [self.innerAlbums removeAllObjects];
    // 获取系统智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [smartAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.selectionType == AlbumListSelectionTypePhoto) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }else if (self.selectionType == AlbumListSelectionTypeVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        // 过滤掉空相册
        if (result.count > 0 && ![[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"最近删除"]) {
            CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
            albumModel.photoCount = result.count;
            albumModel.albumName = collection.localizedTitle;
            albumModel.result = result;
            if ([[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] ||
                [[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                [self.innerAlbums insertObject:albumModel atIndex:0];
            } else {
                [self.innerAlbums addObject:albumModel];
            }
        }
    }];
    
    // 获取用户相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.selectionType == AlbumListSelectionTypePhoto) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }else if (self.selectionType == AlbumListSelectionTypeVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
        // 过滤掉空相册
        if (result.count > 0) {
            CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
            albumModel.photoCount = result.count;
            albumModel.albumName = [CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle];
            albumModel.result = result;
            [self.innerAlbums addObject:albumModel];
        }
    }];
    
    for (int i = 0 ; i < self.albums.count; i++) {
        CTMSGAlbumModel *model = self.albums[i];
        model.index = i;
    }
    if (albums) {
        albums(self.albums);
    }
}

- (void)getAllAlbum:(void (^)(CTMSGAlbumModel * _Nonnull))firstAlbum
             albums:(nonnull void (^)(NSArray<CTMSGAlbumModel *> * _Nonnull))albums
          onlyFirst:(BOOL)onlyFirst {
    if (self.innerAlbums.count > 0) [self.innerAlbums removeAllObjects];
    // 获取系统智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [smartAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (onlyFirst) {
            if ([[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] ||
                [[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                // 是否按创建时间排序
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                if (self.selectionType == AlbumListSelectionTypePhoto) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                } else if (self.selectionType == AlbumListSelectionTypeVideo) {
                    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                }
                // 获取照片集合
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                
                CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
                albumModel.photoCount = result.count;
                albumModel.albumName = collection.localizedTitle;
                albumModel.result = result;
                albumModel.index = 0;
                if (firstAlbum) {
                    firstAlbum(albumModel);
                }
                *stop = YES;
            }
        } else {
            // 是否按创建时间排序
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.selectionType == AlbumListSelectionTypePhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            } else if (self.selectionType == AlbumListSelectionTypeVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            // 获取照片集合
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            // 过滤掉空相册
            if (result.count > 0 && ![[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"最近删除"]) {
                CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
                albumModel.photoCount = result.count;
                albumModel.albumName = collection.localizedTitle;
                albumModel.result = result;
                if ([[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] || [[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
                    [self.innerAlbums insertObject:albumModel atIndex:0];
                } else {
                    [self.innerAlbums addObject:albumModel];
                }
            }
        }
    }];
    if (onlyFirst) {
        return;
    }
    // 获取用户相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 是否按创建时间排序
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        if (self.selectionType == AlbumListSelectionTypePhoto) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        } else if (self.selectionType == AlbumListSelectionTypeVideo) {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        // 获取照片集合
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        
        // 过滤掉空相册
        if (result.count > 0) {
            CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
            albumModel.photoCount = result.count;
            albumModel.albumName = [CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle];
            albumModel.result = result;
            [self.innerAlbums addObject:albumModel];
        }
    }];
    for (int i = 0 ; i < self.albums.count; i++) {
        CTMSGAlbumModel *model = self.innerAlbums[i];
        model.index = i;
    }
    if (albums) {
        albums(self.albums);
    }
}

- (void)getAllPhotoForAlbum:(CTMSGAlbumModel *)albumModel
                   complete:(void (^)(NSArray<CTMSGPhotoModel *> * _Nonnull, NSArray<CTMSGPhotoModel *> * _Nonnull, NSArray<CTMSGPhotoModel *> * _Nonnull, NSArray<CTMSGPhotoModel *> * _Nonnull, CTMSGPhotoModel * _Nonnull))complete {
    NSMutableArray *allArray = [NSMutableArray array];
    NSMutableArray *previewArray = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    NSMutableArray *photoArray = [NSMutableArray array];
    
    __block CTMSGPhotoModel *firstSelectModel;
    NSMutableArray *selectList = [NSMutableArray arrayWithArray:self.selectedList];
    if (self.reverseDate) {
        [albumModel.result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            CTMSGPhotoModel *photoModel = [[CTMSGPhotoModel alloc] init];
            photoModel.asset = asset;
            if ([[asset valueForKey:@"isCloudPlaceholder"] boolValue]) {
                photoModel.isIcloud = YES;
            }
            if (selectList.count > 0) {
                NSString *property = @"asset";
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                NSArray *newArray = [selectList filteredArrayUsingPredicate:pred];
                if (newArray.count > 0) {
                    CTMSGPhotoModel *model = newArray.firstObject;
                    [selectList removeObject:model];
                    photoModel.selected = YES;
                    if ((model.type == CTMSGPhotoModelMediaTypePhoto ||model.type == CTMSGPhotoModelMediaTypeGif) ||
                        model.type == CTMSGPhotoModelMediaTypeLive) {
                        //                        (model.type == CTMSGPhotoModelMediaTypeLive || model.type == PhotoModelMediaTypeCameraPhoto)) {
                        [self.selectedPhotos replaceObjectAtIndex:[self.selectedPhotos indexOfObject:model] withObject:photoModel];
                    } else {
                        [self.selectedVideos replaceObjectAtIndex:[self.selectedVideos indexOfObject:model] withObject:photoModel];
                    }
                    [self.selectedList replaceObjectAtIndex:[self.selectedList indexOfObject:model] withObject:photoModel];
                    photoModel.thumbPhoto = model.thumbPhoto;
                    photoModel.previewPhoto = model.previewPhoto;
                    photoModel.isCloseLivePhoto = model.isCloseLivePhoto;
                    photoModel.selectIndexStr = model.selectIndexStr;
                    if (!firstSelectModel) {
                        firstSelectModel = photoModel;
                    }
                }
            }
            if (asset.mediaType == PHAssetMediaTypeImage) {
                photoModel.subType = CTMSGPhotoModelMediaSubTypePhoto;
                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                    if (self.singleSelected && self.singleSelectedClip) {
                        photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                    } else {
                        photoModel.type = self.showGif ? CTMSGPhotoModelMediaTypeGif : CTMSGPhotoModelMediaTypePhoto;
                    }
                } else {
                    photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                    if (@available(iOS 9.1, *)) {
                        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            if (!self.singleSelected) {
                                photoModel.type = self.showLive ? CTMSGPhotoModelMediaTypeLive : CTMSGPhotoModelMediaTypePhoto;
                            }
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                if (!photoModel.isIcloud) {
                    [photoArray addObject:photoModel];
                }
            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                photoModel.subType = CTMSGPhotoModelMediaSubTypeVideo;
                photoModel.type = CTMSGPhotoModelMediaTypeVideo;
                if (!photoModel.isIcloud) {
                    [videoArray addObject:photoModel];
                }
            }
            photoModel.currentAlbumIndex = albumModel.index;
            [allArray addObject:photoModel];
            if (!photoModel.isIcloud) {
                [previewArray addObject:photoModel];
            }
            
            photoModel.dateItem = allArray.count - 1;
            photoModel.dateSection = 0;
        }];
    } else {
        NSInteger index = 0;
        for (PHAsset *asset in albumModel.result) {
            CTMSGPhotoModel *photoModel = [[CTMSGPhotoModel alloc] init];
            photoModel.asset = asset;
            if ([[asset valueForKey:@"isCloudPlaceholder"] boolValue]) {
                photoModel.isIcloud = YES;
            }
            if (selectList.count > 0) {
                NSString *property = @"asset";
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                NSArray *newArray = [selectList filteredArrayUsingPredicate:pred];
                if (newArray.count > 0) {
                    CTMSGPhotoModel *model = newArray.firstObject;
                    [selectList removeObject:model];
                    photoModel.selected = YES;
                    if ((model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif) ||
                        model.type == CTMSGPhotoModelMediaTypeLive) {
                        //                        (model.type == CTMSGPhotoModelMediaTypeLive || model.type == PhotoModelMediaTypeCameraPhoto)) {
                        [self.selectedPhotos replaceObjectAtIndex:[self.selectedPhotos indexOfObject:model] withObject:photoModel];
                    } else {
                        [self.selectedVideos replaceObjectAtIndex:[self.selectedVideos indexOfObject:model] withObject:photoModel];
                    }
                    [self.selectedList replaceObjectAtIndex:[self.selectedList indexOfObject:model] withObject:photoModel];
                    photoModel.thumbPhoto = model.thumbPhoto;
                    photoModel.previewPhoto = model.previewPhoto;
                    photoModel.isCloseLivePhoto = model.isCloseLivePhoto;
                    photoModel.selectIndexStr = model.selectIndexStr;
                    if (!firstSelectModel) {
                        firstSelectModel = photoModel;
                    }
                }
            }
            if (asset.mediaType == PHAssetMediaTypeImage) {
                photoModel.subType = CTMSGPhotoModelMediaSubTypePhoto;
                if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                    if (self.singleSelected && self.singleSelectedClip) {
                        photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                    } else {
                        photoModel.type = self.showGif ? CTMSGPhotoModelMediaTypeGif : CTMSGPhotoModelMediaTypePhoto;
                    }
                } else {
                    photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                    if (@available(iOS 9.1, *)) {
                        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            if (!self.singleSelected) {
                                photoModel.type = self.showLive ? CTMSGPhotoModelMediaTypeLive : CTMSGPhotoModelMediaTypePhoto;
                            }
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                if (!photoModel.isIcloud) {
                    [photoArray addObject:photoModel];
                }
            } else if (asset.mediaType == PHAssetMediaTypeVideo) {
                photoModel.subType = CTMSGPhotoModelMediaSubTypeVideo;
                photoModel.type = CTMSGPhotoModelMediaTypeVideo;
                if (!photoModel.isIcloud) {
                    [videoArray addObject:photoModel];
                }
            }
            photoModel.currentAlbumIndex = albumModel.index;
            [allArray addObject:photoModel];
            
            if (!photoModel.isIcloud) {
                [previewArray addObject:photoModel];
            }
            photoModel.dateItem = allArray.count - 1;
            photoModel.dateSection = 0;
            index++;
        }
    }
    
    //    if (self.showCamera) {
    //        CTMSGPhotoModel *model = [[CTMSGPhotoModel alloc] init];
    //        model.type = PhotoModelMediaTypeCamera;
    //        if (photoArray.count == 0 && videoArray.count != 0) {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_video@2x.png"];
    //        } else if (photoArray.count == 0) {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_photograph@2x.png"];
    //        } else {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_photograph@2x.png"];
    //        }
    //        if (!self.reverseDate) {
    //            model.dateSection = 0;
    //            model.dateItem = allArray.count;
    //            [allArray addObject:model];
    //        } else {
    //            model.dateSection = 0;
    //            model.dateItem = 0;
    //            [allArray insertObject:model atIndex:0];
    //        }
    //    }
    //    NSInteger cameraIndex = self.showCamera ? 1 : 0;
    //    if (self.cameraList.count > 0) {
    //        NSInteger index = 0;
    //        NSInteger photoIndex = 0;
    //        NSInteger videoIndex = 0;
    //        for (CTMSGPhotoModel *model in self.cameraList) {
    //            model.currentAlbumIndex = albumModel.index;
    //            if (self.reverseDate) {
    //                [allArray insertObject:model atIndex:cameraIndex + index];
    //                [previewArray insertObject:model atIndex:index];
    //                if (model.subType == CTMSGPhotoModelMediaSubTypePhoto) {
    //                    [photoArray insertObject:model atIndex:photoIndex];
    //                    photoIndex++;
    //                }else {
    //                    [videoArray insertObject:model atIndex:videoIndex];
    //                    videoIndex++;
    //                }
    //            } else {
    //                NSInteger count = allArray.count;
    //                [allArray insertObject:model atIndex:count - cameraIndex];
    //                [previewArray addObject:model];
    //                if (model.subType == CTMSGPhotoModelMediaSubTypePhoto) {
    //                    [photoArray addObject:model];
    //                } else {
    //                    [videoArray addObject:model];
    //                }
    //            }
    //            index++;
    //        }
    //    }
    if (complete) {
        complete(allArray, previewArray, photoArray, videoArray, firstSelectModel);
    }
}

- (void)fetchPhotoForPHResult:(PHFetchResult *)result limitCount:(NSInteger)limitCount index:(NSInteger)index result:(void (^)(NSArray<CTMSGPhotoModel *> * _Nonnull, NSArray<CTMSGPhotoModel *> * _Nonnull, NSArray<CTMSGPhotoModel *> * _Nonnull))list {
    NSMutableArray *photoAy = [NSMutableArray array];
    NSMutableArray *videoAy = [NSMutableArray array];
    NSMutableArray *objAy = [NSMutableArray array];
    //    __block NSInteger cameraIndex = self.showCamera ? 1 : 0;
    
    [result enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        CTMSGPhotoModel *photoModel = [[CTMSGPhotoModel alloc] init];
        photoModel.asset = asset;
        if ([[asset valueForKey:@"isCloudPlaceholder"] boolValue]) {
            photoModel.isIcloud = YES;
        }
        if (self.selectedList.count > 0) {
            NSMutableArray *selectedList = [NSMutableArray arrayWithArray:self.selectedList];
            for (CTMSGPhotoModel *model in selectedList) {
                if ([model.asset.localIdentifier isEqualToString:photoModel.asset.localIdentifier]) {
                    photoModel.selected = YES;
                    if ((model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif) ||
                        model.type == CTMSGPhotoModelMediaTypeLive) {
                        //                        (model.type == CTMSGPhotoModelMediaTypeLive || model.type == PhotoModelMediaTypeCameraPhoto)) {
                        [self.selectedPhotos replaceObjectAtIndex:[self.selectedPhotos indexOfObject:model] withObject:photoModel];
                    } else {
                        [self.selectedVideos replaceObjectAtIndex:[self.selectedVideos indexOfObject:model] withObject:photoModel];
                    }
                    [self.selectedList replaceObjectAtIndex:[self.selectedList indexOfObject:model] withObject:photoModel];
                    photoModel.thumbPhoto = model.thumbPhoto;
                    photoModel.previewPhoto = model.previewPhoto;
                    photoModel.isCloseLivePhoto = model.isCloseLivePhoto;
                }
            }
        }
        if (asset.mediaType == PHAssetMediaTypeImage) {
            photoModel.subType = CTMSGPhotoModelMediaSubTypePhoto;
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                if (self.singleSelected && self.singleSelectedClip) {
                    photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                } else {
                    photoModel.type = self.showGif ? CTMSGPhotoModelMediaTypeGif : CTMSGPhotoModelMediaTypePhoto;
                }
            } else {
                photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                if (@available(iOS 9.1, *)) {
                    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                        if (!self.singleSelected) {
                            photoModel.type = self.showLive ? CTMSGPhotoModelMediaTypeLive : CTMSGPhotoModelMediaTypePhoto;
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            if (!photoModel.isIcloud) {
                [photoAy addObject:photoModel];
            }
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            photoModel.subType = CTMSGPhotoModelMediaSubTypeVideo;
            photoModel.type = CTMSGPhotoModelMediaTypeVideo;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                photoModel.avAsset = asset;
            }];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
            photoModel.videoTime = [CTMSGAlbumTool getNewTimeFromDurationSecond:timeLength.integerValue];
            if (!photoModel.isIcloud) {
                [videoAy addObject:photoModel];
            }
        }
        photoModel.currentAlbumIndex = index;
        [objAy addObject:photoModel];
        if (objAy.count >= limitCount) {
            *stop = YES;
        }
    }];
    //    if (self.showCamera) {
    //        CTMSGPhotoModel *model = [[CTMSGPhotoModel alloc] init];
    //        model.type = PhotoModelMediaTypeCamera;
    //        if (photoAy.count == 0 && videoAy.count != 0) {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_video@2x.png"];
    //        }else if (videoAy.count == 0) {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_photograph@2x.png"];
    //        }else {
    //            model.thumbPhoto = [CTMSGAlbumTool imageNamed:@"compose_photo_photograph@2x.png"];
    //        }
    //        [objAy insertObject:model atIndex:0];
    //    }
    //    if (index == 0) {
    //        if (self.cameraList.count > 0) {
    //            for (int i = 0; i < self.cameraList.count; i++) {
    //                CTMSGPhotoModel *phMD = self.cameraList[i];
    //                [objAy insertObject:phMD atIndex:cameraIndex];
    //            }
    //            for (int i = 0; i < self.cameraPhotos.count; i++) {
    //                CTMSGPhotoModel *phMD = self.cameraPhotos[i];
    //                [photoAy insertObject:phMD atIndex:0];
    //            }
    //            for (int i = 0; i < self.cameraVideos.count; i++) {
    //                CTMSGPhotoModel *phMD = self.cameraVideos[i];
    //                [videoAy insertObject:phMD atIndex:0];
    //            }
    //        }
    //    }
    if (list) {
        list(photoAy, videoAy, objAy);
    }
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    NSMutableArray *array = [NSMutableArray array];
    for (CTMSGAlbumModel *albumModel in self.innerAlbums) {
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:albumModel.result];
        if (collectionChanges) {
            [array addObject:@{@"collectionChanges" : collectionChanges ,@"model" : albumModel}];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.selecting) {
            if (self.photoLibraryDidChangeWithPhotoViewController) {
                self.photoLibraryDidChangeWithPhotoViewController(array);
            }
        }
        if (self.photoLibraryDidChangeWithPhotoPreviewViewController) {
            self.photoLibraryDidChangeWithPhotoPreviewViewController(array);
        }
        if (self.photoLibraryDidChangeWithVideoViewController) {
            self.photoLibraryDidChangeWithVideoViewController(array);
        }
        if (array.count == 0 && self.saveCameraPhotoToAlbum) {
            PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.albumModel.result];
            if (collectionChanges) {
                [array addObject:@{@"collectionChanges" : collectionChanges, @"model" : self.albumModel}];
            }
        }
        if (array.count > 0) {
            if (self.photoLibraryDidChangeWithPhotoView) {
                self.photoLibraryDidChangeWithPhotoView(array, self.selecting);
            }
        }
    });
}

#pragma mark - private func

- (void)p_getAlbumToSaveCameraPhoto {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        //        [[UIApplication sharedApplication].keyWindow showImageHUDText:@"无法访问照片，请前往设置中允许\n访问照片"];
        return;
    }
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if ([[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"相机胶卷"] ||
            [[CTMSGAlbumTool transFormPhotoTitle:collection.localizedTitle] isEqualToString:@"所有照片"]) {
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            if (self.selectionType == AlbumListSelectionTypePhoto) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
            } else if (self.selectionType == AlbumListSelectionTypeVideo) {
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
            }
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            CTMSGAlbumModel *albumModel = [[CTMSGAlbumModel alloc] init];
            albumModel.photoCount = result.count;
            albumModel.albumName = collection.localizedTitle;
            albumModel.result = result;
            self.albumModel = albumModel;
            break;
        }
    }
}

#pragma mark - getter

- (NSArray<CTMSGAlbumModel *> *)albums {
    return _innerAlbums;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end
