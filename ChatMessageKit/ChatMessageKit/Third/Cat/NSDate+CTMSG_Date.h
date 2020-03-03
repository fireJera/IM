//
//  NSDate+CTMSG_Date.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (CTMSG_Date)

//@property (nonatomic, assign, readonly, class) NSInteger currentYear;
//@property (nonatomic, assign, readonly, class) NSInteger currentMonth;
//@property (nonatomic, assign, readonly, class) NSInteger currentDay;
//@property (nonatomic, assign, readonly, class) NSInteger currentHour;
//@property (nonatomic, assign, readonly, class) NSInteger currentMinute;

//@property (nonatomic, assign, readonly) NSInteger year;
//@property (nonatomic, assign, readonly) NSInteger month;
//@property (nonatomic, assign, readonly) NSInteger day;
//@property (nonatomic, assign, readonly) NSInteger hour;
//@property (nonatomic, assign, readonly) NSInteger minute;

@property (nonatomic, assign, readonly) BOOL isToday;
@property (nonatomic, assign, readonly) BOOL isYesterday;
@property (nonatomic, assign, readonly) BOOL isThisYear;
//@property (nonatomic, assign, readonly) BOOL isSameWeekWithNow;

///**
// 当前月份有多少天
// */
//@property (nonatomic, assign, readonly) NSInteger daysOfThisMonth;
//
///**
// 本月的第一天的是周几 0-7
// */
//@property (nonatomic, assign, readonly) NSInteger firstDayIntThisMonth;
//@property (nonatomic, copy, readonly) NSString * nowWeekday;            //unknown
//
///**
// 按指定格式获取当前的时间
// 
// @param format 格式
// @return 日期字符串
// */
//- (NSString *)dateStringWithFormat:(NSString *)format;
//- (nullable NSDate *)dateByAddingYears:(NSInteger)years;
//
//- (int)formStrWith:(NSString *)format;
//
///**
// 日期转string
// 
// @param format 输出格式
// @return 日期字符串
// */
//- (NSString *)toString:(NSString *)format;
//
//+ (NSDate *)dateFromBaseDate:(int)year;
//
//+ (NSDate *)dateFromBaseDate:(int)year
//                       month:(int)month
//                         day:(int)day
//                        hour:(int)hour
//                      minute:(int)minute
//                      second:(int)second;
- (NSString *)toString:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
