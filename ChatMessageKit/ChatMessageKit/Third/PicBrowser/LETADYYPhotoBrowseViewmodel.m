//
//  LETADYYPhotoBrowseViewmodel.m
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "LETADYYPhotoBrowseViewmodel.h"
//#import "LETADMHeader.h"
#import "YYPhotoGroupItem.h"
//#import "LETADAlbum.h"

@implementation LETADYYPhotoBrowseViewmodel

#pragma mark - network

//- (void)p_letad_removeAlbum:(LETADAlbum *)album {
//    //TODO: - this for may cause crash
////    [_groupItems makeObjectsPerformSelector:<#(nonnull SEL)#>]
//    YYPhotoGroupItem * outItem;
//    for (YYPhotoGroupItem * item in _groupItems) {
//        if (item.album == album) {
//            outItem = item;
//            if (_groupItems.count == _selectedIndex) {
//                _selectedIndex--;
//            }
//            break;
//        }
//    }
//    [_groupItems removeObject:outItem];
//}

//- (int)sex {
//    return LETADINSTANCE_USER.sex;
//}

- (instancetype)initWithItems:(NSArray<YYPhotoGroupItem *> *)items {
    if (self = [super init]) {
        _groupItems = [items mutableCopy];
    }
    return self;
}

@end
