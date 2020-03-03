//
//  NSDate+CTMSG_Date.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "NSDate+CTMSG_Date.h"

@implementation NSDate (CTMSG_Date)

+ (NSInteger)currentYear {
    return [[NSDate new] year];
}

+ (NSInteger)currentMonth {
    return [[NSDate new] month];
}

+ (NSInteger)currentDay {
    return [[NSDate new] day];
}

+ (NSInteger)currentHour {
    return [[NSDate new] hour];
}

+ (NSInteger)currentMinute {
    return [[NSDate new] minute];
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
    return [self formStrWith:@"MM"];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
    return [self formStrWith:@"dd"];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
    return [self formStrWith:@"HH"];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
    return [self formStrWith:@"mm"];
}

/**
 *  是否为今天
 */
- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}
/**
 *  是否为昨天
 */
- (BOOL)isYesterday {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyyMMdd";
    
    // 生成只有年月日的字符串对象
    NSString *selfString = [fmt stringFromDate:self];
    NSString *nowString = [fmt stringFromDate:[NSDate date]];
    
    // 生成只有年月日的日期对象
    NSDate *selfDate = [fmt dateFromString:selfString];
    NSDate *nowDate = [fmt dateFromString:nowString];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:selfDate toDate:nowDate options:0];
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}

/**
 *  是否为今年
 */
- (BOOL)isThisYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return nowCmps.year == selfCmps.year;
}

/**
 是否为同一周内
 */
- (BOOL)isSameWeekWithNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

- (NSInteger)daysOfThisMonth {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return (int)range.length;
}

- (NSInteger)firstDayIntThisMonth {
    NSDateFormatter * formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM";
    NSMutableString * str = [NSMutableString stringWithFormat:@"%@", [formatter stringFromDate:self]];
    [str appendString:@"-01"];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate * date = [formatter dateFromString:str];
    NSUInteger week = [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    return (int)week - 1;
}

- (NSString *)nowWeekday {
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    [dateday setDateFormat:@"MM月dd日"];
    [dateday setDateFormat:@"EEEE"];
    return [dateday stringFromDate:self];
}

- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = format;
    return[formater stringFromDate:self];
}


- (NSDate *)dateByAddingYears:(NSInteger)years {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 获取yyyy  MM  dd  HH mm ss
 
 - parameter format: 比如 GetFormatDate(yyyy) 返回当前日期年份
 
 - returns: 返回值
 */
- (int)formStrWith:(NSString *)format {
    NSDateFormatter * formatter = [NSDateFormatter new];
    formatter.dateFormat = format;
    NSString * str = [formatter stringFromDate:self];
    NSArray * array = [str componentsSeparatedByString:@""];
    NSString * value;
    if (array) {
        value = array.firstObject;
    }
    return [value intValue];
}

- (NSString *)toString:(NSString *)format {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromBaseDate:(int)year {
    return [NSDate dateFromBaseDate:year month:0 day:0 hour:0 minute:0 second:0];
}

+ (NSDate *)dateFromBaseDate:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second {
    NSDate * nowDate = [NSDate date];
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents * components = nil;
    components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:nowDate];
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:year];
    [dateComponents setMonth:month];
    [dateComponents setDay:day];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    NSDate * newDate = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    return newDate;
}

@end
