//
//  CTMSGAlbumListView.m
//  微博照片选择
//
//  Created by 洪欣 on 17/2/8.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "CTMSGAlbumListView.h"
#import "CTMSGAlbumTool.h"
#import "CTMSGAlbumManager.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGAlbumModel.h"

@interface CTMSGAlbumListView ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) CTMSGAlbumManager *manager;
@end

@implementation CTMSGAlbumListView

- (instancetype)initWithFrame:(CGRect)frame manager:(CTMSGAlbumManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        self.manager = manager;
        self.currentIndex = 0;
        [self p_ctmsg_setup];
    }
    return self;
}

- (void)p_ctmsg_setup {
//    self.backgroundColor = self.manager.UIManager.albumViewBgColor;
    self.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tableView.backgroundColor = self.backgroundColor = self.manager.UIManager.albumViewBgColor;
    tableView.backgroundColor = self.backgroundColor = [UIColor whiteColor];
    [tableView registerClass:[CTMSGAlbumListViewCell class] forCellReuseIdentifier:@"cellId"];
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (void)setList:(NSArray *)list {
    _list = list;
    
    [self.tableView reloadData];
    if (self.currentIndex < list.count) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGAlbumListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.manager = self.manager;
    cell.model = self.list[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndex = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(didTableViewCellClick:animate:)]) {
        [self.delegate didTableViewCellClick:self.list[indexPath.row] animate:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@interface CTMSGAlbumListViewCell ()
@property (strong, nonatomic) UIImageView *photoView;
@property (strong, nonatomic) UILabel *photoName;
@property (strong, nonatomic) UILabel *photoNum;
@property (strong, nonatomic) UIImageView *numIcon;
@property (strong, nonatomic) UIView *selectedView;
@end

@implementation CTMSGAlbumListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self p_ctmsg_setup];
    }
    return self;
}
#pragma mark - < 懒加载 >
- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        _photoView.layer.cornerRadius = 4;
        _photoView.layer.masksToBounds = YES;
    }
    return _photoView;
}
- (UILabel *)photoName {
    if (!_photoName) {
        _photoName = [[UILabel alloc] init];
        _photoName.textColor = [UIColor ctmsgBlackTextColor];
        _photoName.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    }
    return _photoName;
}
- (UILabel *)photoNum {
    if (!_photoNum) {
        _photoNum = [[UILabel alloc] init];
        _photoNum.font = [UIFont systemFontOfSize:12];
    }
    return _photoNum;
}
- (UIImageView *)numIcon {
    if (!_numIcon) {
        _numIcon = [[UIImageView alloc] init];
    }
    return _numIcon;
}
- (UIView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIView alloc] init];
    }
    return _selectedView;
}

- (void)p_ctmsg_setup {
    [self.contentView addSubview:self.photoView];
    [self.contentView addSubview:self.photoName];
    [self.contentView addSubview:self.photoNum];
    [self.photoView addSubview:self.numIcon];
}

- (void)setManager:(CTMSGAlbumManager *)manager {
    _manager = manager;
//    if (manager.UIManager.albumViewCellSelectedColor) {
//        self.selectedView.backgroundColor = manager.UIManager.albumViewCellSelectedColor;
//        self.selectedBackgroundView = self.selectedView;
//    }
    self.photoName.textColor = [UIColor ctmsgBlackTextColor];
    self.photoNum.textColor = [UIColor darkGrayColor];
    if (!self.numIcon.image) {
        self.numIcon.image = [CTMSGAlbumTool ctmsg_imageNamed:@""]; //manager.UIManager.albumViewSelectImageName
    }
//    self.backgroundColor = manager.UIManager.albumViewBgColor;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setModel:(CTMSGAlbumModel *)model {
    _model = model;
    
    __weak typeof(self) weakSelf = self;
    if (!model.asset) {
        model.asset = model.result.lastObject;
        model.albumCover = nil;
    }
    if (model.albumCover) {
        self.photoView.image = model.albumCover;
    }else {
        [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(60, 60) completion:^(UIImage *image, NSDictionary *info) {
            weakSelf.photoView.image = image;
            model.albumCover = image;
        }];
    }
    NSString * albumName = [NSString stringWithFormat:@"%@(%ld)", model.albumName, (long)model.photoCount];
    self.photoName.text = albumName;
    self.photoNum.hidden = YES;
//    self.photoNum.text = [NSString stringWithFormat:@"%ld",(long)model.count];
    if (model.selectCount > 0) {
        self.numIcon.hidden = NO;
    }else {
        self.numIcon.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.photoView.frame = CGRectMake(16, 15, 50, 50);
    self.photoView.center = CGPointMake(self.photoView.center.x, height / 2);
    
    CGFloat photoNameX = CGRectGetMaxX(self.photoView.frame) + 10;
    CGFloat photoNameWith = self.model.nameWidth;
    if (photoNameWith > width - photoNameX - 50) {
        photoNameWith = width - photoNameX - 50;
    }
    photoNameWith = 200;
    self.photoName.frame = CGRectMake(photoNameX, 0, photoNameWith, 18);
    self.photoName.center = CGPointMake(self.photoName.center.x, height / 2);
    
    CGFloat photoNumX = CGRectGetMaxX(self.photoName.frame) + 5;
    CGFloat photoNumWidth = self.ct_w - CGRectGetMaxX(self.photoName.frame) + 5 - 20;
    self.photoNum.frame = CGRectMake(photoNumX, 0, photoNumWidth, 15);
    self.photoNum.center = CGPointMake(self.photoNum.center.x, height / 2 + 2);
    
    CGFloat numIconX = 50 - 2 - 13;
    CGFloat numIconY = 2;
    CGFloat numIconW = 13;
    CGFloat numIconH = 13;
    self.numIcon.frame = CGRectMake(numIconX, numIconY, numIconW, numIconH);
}

@end

