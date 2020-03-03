//
//  INTCTUserDefaults.h
//  LetDate
//
//  Created by Jeremy on 2019/1/19.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "GVUserDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface INTCTUserDefaults : GVUserDefaults

// 设置默认值
- (NSDictionary *)setupDefaults;
// 删除该对象的所有数据
- (void)resetDefaults;

@end

NS_ASSUME_NONNULL_END
