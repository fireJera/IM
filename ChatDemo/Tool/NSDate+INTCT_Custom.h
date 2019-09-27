//
//  NSDate+INTCT_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (INTCT_Custom)

@property (nonatomic, assign, readonly, class) NSInteger currentYear;
@property (nonatomic, assign, readonly, class) NSInteger currentMonth;
@property (nonatomic, assign, readonly, class) NSInteger currentDay;
@property (nonatomic, assign, readonly, class) NSInteger currentHour;
@property (nonatomic, assign, readonly, class) NSInteger currentMinute;

@property (nonatomic, assign, readonly) NSInteger year;
@property (nonatomic, assign, readonly) NSInteger month;
@property (nonatomic, assign, readonly) NSInteger day;
@property (nonatomic, assign, readonly) NSInteger hour;
@property (nonatomic, assign, readonly) NSInteger minute;

@property (nonatomic, assign, readonly) BOOL isToday;
@property (nonatomic, assign, readonly) BOOL isYesterday;
@property (nonatomic, assign, readonly) BOOL isThisYear;
@property (nonatomic, assign, readonly) BOOL isSameWeek;

/**
 当前月份有多少天
 */
@property (nonatomic, assign, readonly) NSInteger daysOfThisMonth;
//
///**
// 本月的第一天的是周几 0-7
// */
@property (nonatomic, assign, readonly) NSInteger firstDayIntThisMonth;
@property (nonatomic, copy, readonly) NSString * nowWeekday;            //unknown

/**
 按指定格式获取当前的时间
 
 @param format 格式
 @return 日期字符串
 */
- (NSString *)dateStringWithFormat:(NSString *)format;

- (int)formStrWith:(NSString *)format;

/**
 日期转string
 
 @param format 输出格式
 @return 日期字符串
 */
- (NSString *)toString:(NSString *)format;

+ (NSInteger)dayOfYear:(NSInteger)year month:(NSInteger)month;

+ (NSDate *)dateFromDateString:(NSString *)string format:(NSString *)dateFormat;

+ (NSDate *)dateFromBaseDate:(int)year;

+ (NSDate *)dateFromBaseDate:(int)year
                       month:(int)month
                         day:(int)day
                        hour:(int)hour
                      minute:(int)minute
                      second:(int)second;

- (nullable NSDate *)dateByAddingYears:(NSInteger)years;

@end

@interface NSDate (INTCTSign)

- (NSString *)dateToSign;

@end


NS_ASSUME_NONNULL_END
