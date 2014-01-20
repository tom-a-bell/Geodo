//
//  ToDoItem.h
//  Geodo
//
//  Created by Tom Bell on 03/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;
@class ToDoList;

@interface ToDoItem : NSManagedObject

@property (nonatomic)         NSInteger index;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSDate   *dueDate;
@property (nonatomic, retain) Place    *place;
@property (nonatomic, retain) ToDoList *list;
@property (nonatomic)         BOOL completed;

- (void)presentNotificationNow;
- (void)scheduleNotificationForDueDate;
- (void)cancelScheduledNotifications;

@end
