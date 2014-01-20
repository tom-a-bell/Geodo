//
//  ItemTableViewCellDelegate.h
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ToDoItem.h"

@class ItemTableViewCell;

// Protocol used by TableViewCell to inform of state changes
@protocol ItemTableViewCellDelegate <NSObject>

// Indicates that the edit process has begun for the given cell
- (void)cellDidBeginEditing:(ItemTableViewCell *)cell;

// Indicates that the edit process has committed for the given cell
- (void)cellDidEndEditing:(ItemTableViewCell *)cell;

// Indicates that the given item has been marked as completed
- (void)markAsCompleted:(ToDoItem *)todoItem;

// Indicates that the given item has been deleted
- (void)deleteItem:(ToDoItem *)todoItem;

// Indicates that the given item has been selected for editing
- (void)editToDoItem:(ToDoItem *)todoItem;

@end
