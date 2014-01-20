//
//  TableViewPressToMove.m
//  ClearStyle
//
//  Created by Tom Bell on 01/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "TableViewPressToMove.h"

@implementation TableViewPressToMove
{
    // The table view that this class extends and adds behavior to
    UITableView *_tableView;

    // Stores the initial position of the touch point in the table view
    CGPoint _initialPosition;

    // Stores the original index and table view cell of the item being pressed
    NSIndexPath *_originalIndex;
    UITableViewCell *_draggedCell;

    // Stores the original location of the cell view
    CGPoint _originalCenter;

    // Stores the centre of the cell that the dragged cell is currently hovering over
    CGPoint _currentCenter;

    // Indicates the current state of the gesture
    BOOL _pressInProgress;
}

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];

    if (self)
    {
        _tableView = tableView;

        // Add the drag recognizers
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(handlePan:)];
        [_tableView addGestureRecognizer:recognizer];
    }

    return self;
}

#pragma mark - Pan Gesture Methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Check for gestures other than the long-press gesture
    if ([gestureRecognizer class] != [UILongPressGestureRecognizer class])
    {
        return NO;
    }

    CGPoint translation = [gestureRecognizer translationInView:[_tableView superview]];

    // Check for vertical gesture
    if (fabsf(translation.y) > fabsf(translation.x))
    {
        return YES;
    }

    return NO;
}

- (void)handlePan:(UILongPressGestureRecognizer *)recognizer
{
    // Step 1
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // Store the initial position of the gesture's touch point
        _initialPosition = [recognizer locationInView:_tableView];

        // Determine the index being pressed upon and store the
        // corresponding table view cell and its centre location
        _originalIndex = [_tableView indexPathForRowAtPoint:_initialPosition];
        _draggedCell = [_tableView cellForRowAtIndexPath:_originalIndex];
        _originalCenter = _draggedCell.center;
        _currentCenter = _originalCenter;

        // Move the cell view to the front of the table view
        [_draggedCell.superview bringSubviewToFront:_draggedCell];

        // Draw a shadow under the cell
        _draggedCell.layer.shadowOffset = CGSizeMake(0.0, +3.0);
        _draggedCell.layer.shadowOpacity = 0.5;
    }

    // Step 2
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Translate the center of the cell vertically
        CGPoint newPosition = [recognizer locationInView:_tableView];
        _draggedCell.center = CGPointMake(_originalCenter.x, _originalCenter.y + (newPosition.y - _initialPosition.y));

        // Calculate if the cell has moved far enough to be inserted between the next pair of rows
        CGPoint newCenter = _currentCenter;
        if ((_currentCenter.y - newPosition.y) > _tableView.rowHeight)
        {
            newCenter.y -= _tableView.rowHeight;
            UITableViewCell *affectedCell = nil;
            for (UITableViewCell *cell in [_tableView visibleCells])
            {
                if (cell.center.y == newCenter.y)
                {
                    affectedCell = cell;
                    break;
                }
            }
            [UIView animateWithDuration:0.2 animations:^{
                affectedCell.center = CGPointMake(affectedCell.center.x, affectedCell.center.y + _tableView.rowHeight);
            }];
        }
        if ((newPosition.y - _currentCenter.y) > _tableView.rowHeight)
        {
            newCenter.y += _tableView.rowHeight;
            UITableViewCell *affectedCell = nil;
            for (UITableViewCell *cell in [_tableView visibleCells])
            {
                if (cell.center.y == newCenter.y)
                {
                    affectedCell = cell;
                    break;
                }
            }
            [UIView animateWithDuration:0.2 animations:^{
                affectedCell.center = CGPointMake(affectedCell.center.x, affectedCell.center.y - _tableView.rowHeight);
            }];
        }
        _currentCenter = newCenter;
    }

    // Step 3
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Determine the row that the dragged cell is positioned over at the end of the gesture
        NSIndexPath *newIndex = [_tableView indexPathForRowAtPoint:[recognizer locationInView:_tableView]];

        // If the new row is different from the original row of the dragged cell, commit the move
        if ([newIndex row] != [_originalIndex row])
        {
            [UIView animateWithDuration:0.2 animations:^{
                _draggedCell.center = _currentCenter;
            }];
            [self.delegate tableView:_tableView moveRowAtIndexPath:_originalIndex toIndexPath:newIndex];
            [_tableView reloadData];
        }
        // Otherwise, move the cell back to its original position
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                _draggedCell.center = _originalCenter;
            }];
            [_tableView reloadData];
        }

        // Remove the shadow under the cell
        _draggedCell.layer.shadowOffset = CGSizeMake(0.0, -3.0);
        _draggedCell.layer.shadowRadius = 3.0;
        _draggedCell.layer.shadowOpacity = 0.0;

    }
}

@end
