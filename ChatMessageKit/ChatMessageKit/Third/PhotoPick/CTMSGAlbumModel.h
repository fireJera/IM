//
//  CTMSGAlbumModel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGAlbumModel : NSObject

/**
 相册名称
 */
@property (nonatomic, copy) NSString * albumName;
/**
 照片数量 也指视频数量
 */
@property (nonatomic, assign) NSInteger photoCount;

/**
 应该是封面
 */
@property (nonatomic, strong) PHAsset * _Nullable asset;
/**
 
 */
@property (nonatomic, strong) PHFetchResult * result;
/**
 应该是封面图片
 */
@property (nonatomic, strong) UIImage * _Nullable albumCover;
/**
 应该是是第几个相册
 */
@property (nonatomic, assign) NSInteger index;

/**
 这个相册被选中的数量
 */
@property (nonatomic, assign) NSInteger selectCount;

/**
 意义不明
 */
@property (nonatomic, assign) CGFloat nameWidth;


@end

NS_ASSUME_NONNULL_END
