//
//  ItemTableViewCell.h
//  ClearStyle
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableViewCell.h"
#import "ToDoItem.h"
#import "ItemTableViewCellDelegate.h"

// A custom table cell that renders a to-do item
@interface ItemTableViewCell : TableViewCell

// The to-do item that  this cell represents
@property (nonatomic) ToDoItem *todoItem;

// The object that acts as delegate for this cell
@property (nonatomic, assign) id<ItemTableViewCellDelegate> delegate;

- (void)markAsCompleted:(BOOL)completed;

@end
