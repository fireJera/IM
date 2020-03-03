//
//  LETADYYPhotoBrowseViewmodel.h
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYPhotoGroupItem;
//@class LETADAlbum;

@interface LETADYYPhotoBrowseViewmodel : NSObject

@property (nonatomic, assign) int selectedIndex;

@property (nonatomic, readonly) NSMutableArray<YYPhotoGroupItem *> *groupItems;
//@property (nonatomic, assign) int sex;

- (instancetype)initWithItems:(NSArray<YYPhotoGroupItem *> *)items;

@end
