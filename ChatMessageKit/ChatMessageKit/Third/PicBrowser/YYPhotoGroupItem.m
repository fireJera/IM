//
//  YYPhotoGroupItem.m
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "YYPhotoGroupItem.h"

@interface YYPhotoGroupItem () <NSCopying>

- (BOOL)p_letad_shouldClipToTop:(CGSize)imageSize forView:(UIView *)view;

@end

@implementation YYPhotoGroupItem

- (id)copyWithZone:(NSZone *)zone {
    YYPhotoGroupItem *item = [self.class new];
    return item;
}

- (BOOL)p_letad_shouldClipToTop:(CGSize)imageSize forView:(UIView *)view {
    if (view.frame.size.width < 1 || view.frame.size.height < 1) return NO;
    if (imageSize.width < 1 || imageSize.height < 1) return NO;
    return imageSize.height / imageSize.width > view.frame.size.width / view.frame.size.height;
}

- (BOOL)thumbClippedToTop {
    if (_thumbView) {
        if (_thumbView.layer.contentsRect.size.height < 1) return YES;
    }
    return NO;
}

- (UIImage *)thumbImage {
    if ([_thumbView respondsToSelector:@selector(image)]) {
        UIImage * image = ((UIImageView *)_thumbView).image;
        if (!image) {
            if ([_thumbView isKindOfClass:[UIButton class]]) {
                UIButton * button = (UIButton *)_thumbView;
                image = button.imageView.image;
                if (_isBtnBg) image = [button currentBackgroundImage];
            }
        }
        return image;
    }
    return nil;
}

@end
