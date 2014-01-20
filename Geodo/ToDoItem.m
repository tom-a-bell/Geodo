//
//  ToDoItem.m
//  Geodo
//
//  Created by Tom Bell on 03/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ToDoItem.h"
#import "ToDoList.h"

@implementation ToDoItem

@dynamic index;
@dynamic text;
@dynamic notes;
@dynamic dueDate;
@dynamic place;
@dynamic list;
@dynamic completed;
@dynamic reference;

- (void)presentNotificationNow
{
    // Create the local notification
    UILocalNotification *localNotification = [self createLocalNotification];

    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)scheduleNotificationForDueDate
{
    // Do not schedule a notification if the due date is nil
    if (self.dueDate == nil)
    {
        return;
    }

    // Create the local notification
    UILocalNotification *localNotification = [self createLocalNotification];

    // Set the notification fire date
    localNotification.fireDate = self.dueDate;
    NSLog(@"Notification set for %@", self.dueDate);

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)scheduleNotificationForDueDateAtTime:(NSDateComponents *)timeComponents
{
    // Do not schedule a notification if the due date is nil
    if (self.dueDate == nil)
    {
        return;
    }

    // Create the local notification
    UILocalNotification *localNotification = [self createLocalNotification];

    // Extract the year, month and day of the due date
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *alarmComponents = [calendar components:unitFlags fromDate:self.dueDate];

    // Set the alarm time from the supplied date components
    [alarmComponents setHour:timeComponents.hour];
    [alarmComponents setMinute:timeComponents.minute];
    NSDate *alarmDate = [calendar dateFromComponents:alarmComponents];

    // Set the notification fire date
    localNotification.fireDate = alarmDate;
    NSLog(@"Notification set for %@", alarmDate);

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)cancelScheduledNotifications
{
    // Find relevant notifications based on the associated item reference
    for (UILocalNotification *localNotification in [[UIApplication sharedApplication] scheduledLocalNotifications])
    {
        if ([[localNotification.userInfo objectForKey:@"ItemReference"] isEqualToString:self.reference])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

#pragma mark - Utility Methods

- (UILocalNotification *)createLocalNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil)
    {
        return nil;
    }

    // Specify the notification properties
    localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), self.text];
    localNotification.alertAction = NSLocalizedString(@"View Details", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.applicationIconBadgeNumber = 1;

    // Store the item and list properties in the userInfo dictionary
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.text, @"ItemDescription",
                              self.reference, @"ItemReference",
                              self.list.name, @"ItemList", nil];
    localNotification.userInfo = infoDict;

    return localNotification;
}

@end
