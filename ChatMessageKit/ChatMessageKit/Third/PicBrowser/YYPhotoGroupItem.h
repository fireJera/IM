//
//  YYPhotoGroupItem.h
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@class LETADAlbum;

/// Single picture's info.
@interface YYPhotoGroupItem : NSObject

@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, assign, readonly) BOOL thumbClippedToTop;
@property (nonatomic, readonly) UIImage *thumbImage;
@property (nonatomic, assign) BOOL isBtnBg;
//@property (nonatomic, strong) LETADAlbum * album;

@end
