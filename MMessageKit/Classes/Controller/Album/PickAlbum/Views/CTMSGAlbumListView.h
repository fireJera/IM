//
//  CTMSGAlbumListView.h
//  微博照片选择
//
//  Created by 洪欣 on 17/2/8.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CTMSGAlbumModel.h"

@class CTMSGAlbumModel;

@protocol CTMSGAlbumListViewDelegate <NSObject>

- (void)didTableViewCellClick:(CTMSGAlbumModel *)model animate:(BOOL)anim;

@end

@class CTMSGAlbumManager;
@interface CTMSGAlbumListView : UIView
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id<CTMSGAlbumListViewDelegate> delegate;
@property (copy, nonatomic) NSArray *list;
@property (assign, nonatomic) NSInteger currentIndex;
- (instancetype)initWithFrame:(CGRect)frame manager:(CTMSGAlbumManager *)manager;
@end

@interface CTMSGAlbumListViewCell : UITableViewCell
@property (strong, nonatomic) CTMSGAlbumModel *model;
@property (weak, nonatomic) CTMSGAlbumManager *manager;
@end
