//
//  CTMSGEmoticonTabSource.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 自定义表情view数据源代理
 */
@protocol CTMSGEmoticonTabSource <NSObject>

/*!
 表情tab的标识符
 @return 表情tab的标识符，请勿重复
 */
- (NSString *)identify;

/*!
 表情tab的图标
 @return 表情tab的图标
 */
- (UIImage *)image;

/*!
 表情tab的页数
 @return 表情tab的页数
 */
- (int)pageCount;
/*!
 表情tab的index页的表情View
 
 @return 表情tab的index页的表情View
 @discussion 返回的 view 大小必须等于 contentViewSize （宽度 = 屏幕宽度，高度 = 186）
 */
- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index;
@end


