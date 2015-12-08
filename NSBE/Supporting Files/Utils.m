//
//  Utils.m
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import "Utils.h"
#import "XOR.h"
#import "Reachability.h"

@implementation Utils

+ (NSString *)nilToString:(NSString *)string {
    return string != nil ? string : @"";
}

+ (NSString *)dateToSQLDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";

    // Sanity check
    if (!date) {
        return [dateFormatter stringFromDate:[NSDate date]];
    }

    // Return SQL formatted date string
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)SQLStringDateToDate:(NSString *)string {
    // Sanity check
    if ([string length] == 0) {
        return nil;
    }

    // Convert SQL date
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    [dateFromatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFromatter dateFromString:string];
}

+ (NSDate *)facebookStringDateToDate:(NSString *)string {
    // Sanity check
    if ([string length] == 0) {
        return nil;
    }

    // Convert Facebook date
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    [dateFromatter setDateFormat:@"MM/dd/yyyy"];
    return [dateFromatter dateFromString:string];
}

+ (BOOL)isValidEmail:(NSString *)email {
    // Sanity check
    if ([email length] == 0) {
        return NO;
    }

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:email];
}

+ (NSNumber *)numberFromString:(NSString *)string {
    static NSNumberFormatter *numberFormatter;

    if (!numberFormatter) {

        // Create single instance of number formatter
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }

    // Convert and return the number
    return [numberFormatter numberFromString:string];
}

+ (NSArray *)numbersFromString:(NSString *)string {
    // Sanity check
    if ([string length] == 0) {
        return nil;
    }

    // Extract all the number strings from the given string
    NSString *strippedNumbers = [string stringByReplacingOccurrencesOfString:@"[^0-9]"
                                                                  withString:@" "
                                                                     options:NSRegularExpressionSearch
                                                                       range:NSMakeRange(0, [string length])];
    NSArray *numberStrings = [strippedNumbers componentsSeparatedByString:@" "];

    // Create the mutable array to store all the numbers
    NSMutableArray *numbers = [[NSMutableArray alloc] init];

    // Loop through number strings and add the converted number to numbers array
    for (NSString *numberString in numberStrings) {
        if ([numberString length] != 0) {
            [numbers addObject:[Utils numberFromString:numberString]];
        }
    }

    // Return the converted numbers array
    return numbers;
}

+ (NSInteger)getMinuteFromDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:date];
    return components.minute;
}

+ (NSInteger)getHourFromDate:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date];
    return components.hour;
}

+ (NSInteger)getCurrentYear {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    return dateComponents.year;
}

+ (NSInteger)getCurrentMonth {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]];
    return dateComponents.month;
}

+ (NSInteger)getCurrentDay {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    return dateComponents.day;
}

+ (NSInteger)getYearCountFromDate:(NSDate *)date {
    // Sanity check
    if (!date) {
        return 0;
    }

    // Get date components
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                       fromDate:date
                                                                         toDate:[NSDate date]
                                                                        options:0];
    // Return years from date components
    return dateComponents.year;
}

+ (NSArray *)getPastYears:(NSInteger)count includeCurrentYear:(BOOL)includeCurrentYear {
    // Sanity checks
    if (count <= 0) {
        return @[];
    }

    // Get current year
    NSMutableArray *pastYears = [[NSMutableArray alloc] initWithCapacity:count];
    NSInteger currentYear = [Utils getCurrentYear];
    NSInteger startYear = includeCurrentYear ? currentYear : currentYear - 1;

    for (int i = (int) startYear; i > startYear - count; i--) {
        [pastYears addObject:@(i)];
    }

    // Return past years
    return pastYears;
}

+ (NSArray *)getAllMonths {
    return [[[NSDateFormatter alloc] init] monthSymbols];
}

+ (NSArray *)getAllDaysInMonth:(NSInteger)month year:(NSInteger)year {
    // Sanity checks
    if (month < 0 && month > 12) {
        return @[];
    }

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

    // Set year and month
    [dateComponents setYear:year];
    [dateComponents setMonth:month];

    // Get day count in that year and month
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayCount = [calendar rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:[calendar dateFromComponents:dateComponents]].length;

    // Create an array with the days
    NSMutableArray *days = [[NSMutableArray alloc] initWithCapacity:dayCount];

    for (int i = 1; i <= dayCount; i++) {
        [days addObject:@(i)];
    }

    // Return all the days
    return days;
}

+ (BOOL)isDate:(NSDate *)firstDate sameDayAsDate:(NSDate *)secondDate {
    NSDateComponents *dateComponents1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth |
            NSCalendarUnitDay                                           fromDate:firstDate];
    NSDateComponents *dateComponents2 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth |
            NSCalendarUnitDay                                           fromDate:secondDate];

    return ([dateComponents1 day] == [dateComponents2 day] &&
            [dateComponents1 month] == [dateComponents2 month] &&
            [dateComponents1 year] == [dateComponents2 year]);
}

+ (NSString *)getOrdinalNumberSuffix:(NSNumber *)number {
    // Sanity checks
    if (!number) {
        return nil;
    }

    // Return the suffix based on the last character
    NSString *stringNumber = [number stringValue];
    switch ([stringNumber characterAtIndex:stringNumber.length - 1]) {
        case '0':
            return @"";
        case '1':
        case '2':
        case '3': {
            if ([stringNumber length] > 1 && [stringNumber characterAtIndex:stringNumber.length - 2] == '1') {
                return @"th";
            } else {
                switch ([stringNumber characterAtIndex:stringNumber.length - 1]) {
                    case '1':
                        return @"st";
                    case '2':
                        return @"nd";
                    case '3':
                        return @"rd";
                }
            }
        }
        default: {
            return @"th";
        }
    }
}

+ (NSString *)getGroupedStringNumber:(NSNumber *)number {
    // Set number formatter properties
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setGroupingSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setAlwaysShowsDecimalSeparator:NO];
    [numberFormatter setUsesGroupingSeparator:YES];

    // Return the formatted number
    if (![numberFormatter stringFromNumber:number]) {
        return @"0";
    } else {
        return [numberFormatter stringFromNumber:number];
    }
}

+ (NSString *)encodedBase64XORString:(NSString *)string {
    NSData *stringData = [XOR encryptString:string];
    return [stringData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
}

+ (NSString *)encodedBase64String:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
}

+ (NSString *)decodedBase64String:(NSString *)string {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (UIImage *)getDeviceLaunchScreenImage {
    NSDictionary *launchImagesNames = @{@"320x480" : @"LaunchImage-700",
            @"320x568" : @"LaunchImage-700-568h",
            @"375x667" : @"LaunchImage-800-667h",
            @"414x736" : @"LaunchImage-800-Portrait-736h"};
    NSString *key = [NSString stringWithFormat:@"%dx%d",
                                               (int) [UIScreen mainScreen].bounds.size.width,
                                               (int) [UIScreen mainScreen].bounds.size.height];
    return [UIImage imageNamed:launchImagesNames[key]];
}

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&fromDate
                 interval:NULL
                  forDate:fromDateTime];

    [calendar rangeOfUnit:NSCalendarUnitDay
                startDate:&toDate
                 interval:NULL
                  forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate
                                                 toDate:toDate
                                                options:0];
    return [difference day];
}

+ (NSInteger)weeksBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units = NSWeekCalendarUnit;
    NSDateComponents *components = [calendar components:units
                                               fromDate:fromDateTime
                                                 toDate:toDateTime
                                                options:0];

    return [components week];

}

+ (NSInteger)minutesBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    [calendar rangeOfUnit:NSCalendarUnitMinute
                startDate:&fromDate
                 interval:NULL
                  forDate:fromDateTime];

    [calendar rangeOfUnit:NSCalendarUnitMinute
                startDate:&toDate
                 interval:NULL
                  forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitMinute
                                               fromDate:fromDate
                                                 toDate:toDate
                                                options:0];
    return [difference minute];
}

+ (NSDate *)dateTimeWithString:(NSString *)string {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:string];
    return date;
}

+ (BOOL)isNetworkConnectionAvailable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return reachability.isReachable;
}

+ (NSDate *)dateWithOutTime:(NSDate *)datDate {
    if (datDate == nil) {
        datDate = [NSDate date];
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
