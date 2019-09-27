//
//  NSDate+INTCT_Custom.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSDate+INTCT_Custom.h"

@implementation NSDate (INTCT_Custom)

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
- (BOOL)isSameWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}


/**
 这个月有几天
 - parameter date: NSDate
 - returns: 天数
 */
- (NSInteger)daysOfThisMonth {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return (int)range.length;
}

+ (NSInteger)dayOfYear:(NSInteger)year month:(NSInteger)month {
    NSDate * date = [self dateFromBaseDate:(int)year month:(int)month day:0 hour:0 minute:0 second:0];
    return [date daysOfThisMonth];
}

/**
 得到本月的第一天的是周几
 
 - parameter date: nsdate
 
 - returns: 周几
 */

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

+ (NSDate *)dateFromDateString:(NSString *)string format:(NSString *)dateFormat {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = dateFormat;
    return [formatter dateFromString:string];
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

- (NSDate *)dateByAddingYears:(NSInteger)years {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    [components setYear:years];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end


#pragma mark - INTCTSign

@implementation NSDate (INTCTSign)

- (NSString *)dateToSign {
    int i_month = 0, i_day=0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    
    NSString *theMonth = [dateFormat stringFromDate:self];
    i_month = [theMonth intValue];
    
    [dateFormat setDateFormat:@"dd"];
    NSString *theDay = [dateFormat stringFromDate:self];
    i_day = [theDay intValue];
    
    /*
     
     摩羯座 12月22日------1月19日
     
     水瓶座 1月20日-------2月18日
     
     双鱼座 2月19日-------3月20日
     
     白羊座 3月21日-------4月19日
     
     金牛座 4月20日-------5月20日
     
     双子座 5月21日-------6月21日
     
     巨蟹座 6月22日-------7月22日
     
     狮子座 7月23日-------8月22日
     
     处女座 8月23日-------9月22日
     
     天秤座 9月23日------10月23日
     
     天蝎座 10月24日-----11月21日
     
     射手座 11月22日-----12月21日
     
     */
    NSString *retStr=@"";
    if (i_month == 1) {
        if(i_day>=20 && i_day<=31){
            retStr=@"水瓶座";
        }
        if(i_day>=1 && i_day<=19){
            retStr=@"摩羯座";
        }
    }
    else if (i_month == 2) {
        if(i_day>=1 && i_day<=18){
            retStr=@"水瓶座";
        }
        if(i_day>=19 && i_day<=31){
            retStr=@"双鱼座";
        }
    }
    else if (i_month == 3) {
        if(i_day>=1 && i_day<=20){
            retStr=@"双鱼座";
        }
        if(i_day>=21 && i_day<=31){
            retStr=@"白羊座";
        }
    }
    else if (i_month == 4) {
        if(i_day>=1 && i_day<=19){
            retStr=@"白羊座";
        }
        if(i_day>=20 && i_day<=31){
            retStr=@"金牛座";
        }
    }
    else if (i_month == 5) {
        if(i_day>=1 && i_day<=20){
            retStr=@"金牛座";
        }
        if(i_day>=21 && i_day<=31){
            retStr=@"双子座";
        }
    }
    else if (i_month == 6) {
        if(i_day>=1 && i_day<=21){
            retStr=@"双子座";
        }
        if(i_day>=22 && i_day<=31){
            retStr=@"巨蟹座";
        }
    }
    else if (i_month == 7) {
        if(i_day>=1 && i_day<=22){
            retStr=@"巨蟹座";
        }
        if(i_day>=23 && i_day<=31){
            retStr=@"狮子座";
        }
    }
    else if (i_month == 8) {
        if(i_day>=1 && i_day<=22){
            retStr=@"狮子座";
        }
        if(i_day>=23 && i_day<=31){
            retStr=@"处女座";
        }
    }
    else if (i_month == 9) {
        if(i_day>=1 && i_day<=22){
            retStr=@"处女座";
        }
        if(i_day>=23 && i_day<=31){
            retStr=@"天秤座";
        }
    }
    else if (i_month == 10) {
        if(i_day>=1 && i_day<=23){
            retStr=@"天秤座";
        }
        if(i_day>=24 && i_day<=31){
            retStr=@"天蝎座";
        }
    }
    else if (i_month == 11) {
        if(i_day>=1 && i_day<=21){
            retStr=@"天蝎座";
        }
        if(i_day>=22 && i_day<=31){
            retStr=@"射手座";
        }
    }
    else if (i_month == 12) {
        if(i_day>=1 && i_day<=21){
            retStr=@"射手座";
        }
        if(i_day>=22 && i_day<=31){
            retStr=@"摩羯座";
        }
    }
    return retStr;
}

@end

