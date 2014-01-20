//
//  PlaceholderCellDelegate.h
//  ClearStyle
//
//  Created by Tom Bell on 15/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

@class PlaceholderCell;

// Protocol used by PlaceholderCell to inform of state changes
@protocol PlaceholderCellDelegate <NSObject>

// Indicates that the edit process has begun for the given cell
- (void)cellDidBeginEditing:(PlaceholderCell *)cell;

// Indicates that the edit process has committed for the given cell
- (void)cellDidEndEditing:(PlaceholderCell *)cell;

// Indicates that a new to-do item should be created from the given cell
- (void)addItemFromPlaceholderCell:(PlaceholderCell *)cell;

@end
