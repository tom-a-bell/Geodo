//
//  PlaceholderCell.h
//  Geodo
//
//  Created by Tom Bell on 15/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableViewCell.h"
#import "PlaceholderCellDelegate.h"

// A custom table cell that renders ToDoItem items
@interface PlaceholderCell : TableViewCell <UITextFieldDelegate>

// The object that acts as delegate for this cell
@property (nonatomic, assign) id<PlaceholderCellDelegate> delegate;

@end
