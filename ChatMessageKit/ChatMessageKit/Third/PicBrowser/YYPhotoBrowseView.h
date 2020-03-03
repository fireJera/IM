//
//  YYPhotoGroupFace.h
//
//  Created by ibireme on 14/3/9.
//  Copyright (C) 2014 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYPhotoGroupItem.h"
#import "YYPhotoGroupCell.h"

@class YYPhotoBrowseView;
//@class LETADAlbum;

@protocol YYPhotoBrowseFuncDelegate <NSObject>

@optional
//- (void)letad_browserViewWillClose:(YYPhotoBrowseView *)browseView;
- (void)letad_editPhoto:(YYPhotoBrowseView *)browseView index:(int)index item:(YYPhotoGroupItem *)item;

@end

@interface YYPhotoBrowseView : UIView
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground;
@property (nonatomic, assign) BOOL showEdit;

@property (nonatomic, weak) id<YYPhotoBrowseFuncDelegate> delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithGroupItems:(NSArray *)groupItems;
- (void)letad_presentFromImageView:(UIView *)fromFace
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

//- (void)letad_removeAlbum:(LETADAlbum *)album;

- (void)letad_dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)letad_dismiss;

@end
