//
//  CTMSGAlbumModel.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAlbumModel.h"
#import "CTMSGAlbumTool.h"

@implementation CTMSGAlbumModel

- (CGFloat)albumNameWidth {
    if (_nameWidth == 0) {
        _nameWidth = [CTMSGAlbumTool getTextWidth:self.albumName height:18 fontSize:17];
    }
    return _nameWidth;
}

@end
