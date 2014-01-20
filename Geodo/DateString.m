//
//  DateString.m
//  Geodo
//
//  Created by Tom Bell on 19/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "DateString.h"

@implementation DateString

static NSDateFormatter *weekdayDateFormatter = nil;
static NSDateFormatter *relativeDateFormatter = nil;

+ (NSString *)stringForDate:(NSDate *)date
{
    // Extract the year, month and day of the current date
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];

    // Create a date corresponding to midnight on the current day
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    NSDate *currentDay = [calendar dateFromComponents:dateComponents];

    if ([date compare:[currentDay dateByAddingTimeInterval:2*24*60*60]] == NSOrderedDescending &&
        [date compare:[currentDay dateByAddingTimeInterval:7*24*60*60]] == NSOrderedAscending)
    {
        if (!weekdayDateFormatter)
        {
            weekdayDateFormatter = [[NSDateFormatter alloc] init];
            weekdayDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
        }
        return [weekdayDateFormatter stringFromDate:date];
    }

    if (!relativeDateFormatter)
    {
        relativeDateFormatter = [[NSDateFormatter alloc] init];
        [relativeDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [relativeDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [relativeDateFormatter setDoesRelativeDateFormatting:YES];
    }
    return [relativeDateFormatter stringFromDate:date];
}

@end
