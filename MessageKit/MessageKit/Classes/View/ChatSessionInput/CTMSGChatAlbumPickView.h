//
//  CTMSGChatAlbumPickView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTMSGChatAlbumPickViewDelegate;

@interface CTMSGChatAlbumPickView : UIView

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIButton * albumBtn;
@property (nonatomic, strong) UIButton * sendBtn;

@property (nonatomic, weak) id<CTMSGChatAlbumPickViewDelegate> delegate;

@end

@protocol CTMSGChatAlbumPickViewDelegate <NSObject>

- (void)sendImages:(NSArray<UIImage *> *)images;

- (void)pickViewClickOpenAlbum;
- (void)pickNumBeyondMax;

@end

NS_ASSUME_NONNULL_END
