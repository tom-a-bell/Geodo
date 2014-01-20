//
//  ListTableViewCell.h
//  ClearStyle
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableViewCell.h"
#import "ToDoList.h"
#import "Place.h"

// A custom table cell that renders a to-do list entry
@interface ListTableViewCell : TableViewCell

// The to-do list that this cell represents
@property (nonatomic) ToDoList *todoList;

// The location that this cell represents
@property (nonatomic) Place *place;

// The date range that this cell represents
@property (nonatomic, copy) NSString *dateRange;

// An indicator label for the selected state
@property (strong, nonatomic) UILabel *indicatorLabel;

// The string used for the indicator symbol
@property (nonatomic, copy) NSString *indicatorSymbol;

@end
