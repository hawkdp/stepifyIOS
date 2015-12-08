//
//  Utils.h
//  NSBE
//
//  Created by Iulian Corcoja on 1/23/15.
//  Copyright (c) 2015 Adelante Consulting Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

/**
 Returns the string received as a parameter or an empty string if the parameter is nil.
 
 @param string The string to be tested for nil value.
 
 @return An instance of NSString.
 */
+ (NSString *)nilToString:(NSString *)string;

/**
 Converts date received as a parameter to SQL date format.
 
 @param date The date to be converted.
 
 @remarks SQL date format is "yyyy-MM-dd".
 
 @return A string with the date in SQL date format.
 */
+ (NSString *)dateToSQLDate:(NSDate *)date;

/**
 Converts string received as a parameter to a date.
 
 @param string The string in SQL date format to be converted.
 
 @remarks SQL date format is "yyyy-MM-dd".
 
 @return A date converted from the string with SQL date format.
 */
+ (NSDate *)SQLStringDateToDate:(NSString *)string;

/**
 Converts string received as a parameter to a date.
 
 @param string The string in Facebook date format to be converted.
 
 @remarks Facebook date format is "MM/dd/yyyy".
 
 @return A date converted from the string with SQL date format.
 */
+ (NSDate *)facebookStringDateToDate:(NSString *)string;

/**
 Returns YES if the email string received as a parameter is a valid email or NO otherwise.
 
 @param email The email string to be tested for validity.
 
 @return A boolean value.
 */
+ (BOOL)isValidEmail:(NSString *)email;

/**
 Returns the number converted from a given string.
 
 @param string The string that contains a number.
 
 @return A number converted from the string.
 */
+ (NSNumber *)numberFromString:(NSString *)string;

/**
 Returns all the numbers from a given string.
 
 @param string The string that contains any numbers.
 
 @return An array with the numbers extracted from the string.
 */
+ (NSArray *)numbersFromString:(NSString *)string;

/**
 Returns the minute of the hour from a given date.
 
 @param date The date from which the minute will be extracted.
 
 @return An integer containing the minute of the hour from date.
 */
+ (NSInteger)getMinuteFromDate:(NSDate *)date;

/**
 Returns the hour from a given date.
 
 @param date The date from which the hour will be extracted.
 
 @return An integer containing the hour from date.
 */
+ (NSInteger)getHourFromDate:(NSDate *)date;

/**
 Returns the current year.
 
 @return An integer with the current year.
 */
+ (NSInteger)getCurrentYear;

/**
 Returns the current month in this year.
 
 @return An integer with the month in this year.
 */
+ (NSInteger)getCurrentMonth;

/**
 Returns the current day in this month.
 
 @return An integer with the day in this month.
 */
+ (NSInteger)getCurrentDay;

/**
 Calculates the year count that passed from a given date until today.
 
 @param date The date to calculate years from.
 
 @return An integer representing passed years.
 */
+ (NSInteger)getYearCountFromDate:(NSDate *)date;

/**
 Returns an array with all the past years since now. The count of past years is specified
 by a parameter.
 
 @param count The count of past years to be returned (including current year if this is selected).
 @param includeCurrentYear Set whether to include or not the current year in the returned array.
 
 @return An array of numbers containing past years.
 */
+ (NSArray *)getPastYears:(NSInteger)count includeCurrentYear:(BOOL)includeCurrentYear;

/**
 Returns an array with all the month names in a year.
 
 @return An array of strings containing month names.
 */
+ (NSArray *)getAllMonths;

/**
 Returns an array with all days in a specific year and month.
 
 @param month The month from which to get the days.
 @param year The year from which to get the month.
 
 @return An array of numbers containing all the days in the specified year and month.
 */
+ (NSArray *)getAllDaysInMonth:(NSInteger)month year:(NSInteger)year;

/**
 Returns true if the two dates are in the same day.
 
 @param firstDate First date.
 @param secondDate Second date.
 
 @return A boolean value indicating if two dates are in the same day.
 */
+ (BOOL)isDate:(NSDate *)firstDate sameDayAsDate:(NSDate *)secondDate;

/**
 Returns the suffix of the received ordinal number.
 
 @param number The ordinal number.
 
 @return A string containing the suffix of the ordinal number.
 */
+ (NSString *)getOrdinalNumberSuffix:(NSNumber *)number;

/**
 Returns the number represented as a string using digit grouping. Comma is used as a
 grouping separator.
 
 @param number The number to be formatted.
 
 @return A string containing the formatted number using digit grouping.
 */
+ (NSString *)getGroupedStringNumber:(NSNumber *)number;

/**
 Encodes the original string with XOR in Base64 represenation.
 
 @param string The string to be encoded.
 
 @return A string encoded with XOR in Base64 represenation.
 */
+ (NSString *)encodedBase64XORString:(NSString *)string;

/**
 Encodes the original string in Base64 represenation.
 
 @param string The string to be encoded.
 
 @return A string encoded in Base64 represenation.
 */
+ (NSString *)encodedBase64String:(NSString *)string;

/**
 Decodes the Base64 represented string back to original.
 
 @param string The string to be decoded.
 
 @return A string decoded from string in Base64 represenation.
 */
+ (NSString *)decodedBase64String:(NSString *)string;

/**
 Returns the launch screen based on the device's screen size;
 
 @return The image used for launch screen.
 */
+ (UIImage *)getDeviceLaunchScreenImage;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)weeksBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)minutesBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSDate *)dateTimeWithString:(NSString *)string;
+ (BOOL)isNetworkConnectionAvailable;
+ (NSDate *)dateWithOutTime:(NSDate *)datDate;
@end
