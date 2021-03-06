//
//  CTMSGPhotoCustomNavigationBar.m
//  微博照片选择
//
//  Created by 洪欣 on 2017/9/22.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "CTMSGPhotoCustomNavigationBar.h"
#import "CTMSGAlbumTool.h"
#import "CTMSGUtilities.h"
#import "UIView+CTMSG_Cat.h"

@implementation CTMSGPhotoCustomNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.ct_h = CTMSGNavBarHeight;
        for (UIView *view in self.subviews) {
            if([NSStringFromClass([view class]) containsString:@"Background"]) {
                view.frame = self.bounds;
            }
            else if ([NSStringFromClass([view class]) containsString:@"ContentView"]) {
                CGRect frame = view.frame;
                frame.origin.y = CTMSGNavBarHeight - 44;
                frame.size.height = self.bounds.size.height - frame.origin.y;
                view.frame = frame;
            }
        }
    }
#endif
}

@end
