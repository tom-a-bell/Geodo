//
//  ListTableViewControllerDelegate.h
//  Geodo
//
//  Created by Tom Bell on 01/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

@class ToDoList;
@class Place;

// Protocol used by ListTableViewController to inform of state changes
@protocol ListTableViewControllerDelegate <NSObject>

@optional

// Indicates that the given to-do list has been selected
- (void)toDoListSelected:(ToDoList *)todoList;

// Indicates that the given date range has been selected
- (void)dateRangeSelected:(NSInteger)dateRange;

// Indicates that the given location has been selected
- (void)locationSelected:(Place *)place;

@end
