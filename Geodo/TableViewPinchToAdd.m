//
//  TableViewPinchToAdd.m
//  Geodo
//
//  Created by Tom Bell on 27/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "TableViewPinchToAdd.h"
#import "ItemTableViewCell.h"

// Structure representing the upper and lower points of a pinch gesture
struct TouchPoints
{
    CGPoint upper;
    CGPoint lower;
};
typedef struct TouchPoints TouchPoints;

@implementation TableViewPinchToAdd
{
    // The table view that this class extends and adds behavior to
    UITableView *_tableView;

    // Placeholder cell to indicate where a new item is to be added
    ItemTableViewCell *_placeholderCell;

    // Indices of the upper and lower cells that are being pinched
    int _pointOneCellIndex;
    int _pointTwoCellIndex;

    // Location of the touch points when the pinch began
    TouchPoints _initialTouchPoints;

    // Indicates the current state of the gesture
    BOOL _pinchInProgress;

    // Indicates that the pinch was big enough to cause a new item to be added
    BOOL _pinchExceededRequiredDistance;
}

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        // Create the placeholder cell to use for “pull to add” gestures
        _placeholderCell = [[ItemTableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor whiteColor];
        _placeholderCell.itemLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderCell.editButton.hidden = YES;

        _tableView = tableView;

        // Add a pinch recognizer
        UIGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [_tableView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self pinchStarted:recognizer];
    }

    if (recognizer.state == UIGestureRecognizerStateChanged && _pinchInProgress && recognizer.numberOfTouches == 2)
    {
        [self pinchChanged:recognizer];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self pinchEnded:recognizer];
    }

}

- (void)pinchStarted:(UIPinchGestureRecognizer *)recognizer
{
    // Find the two touch points
    _initialTouchPoints = [self getNormalisedTouchPoints:recognizer];

    // Create points half a cell above and below the midpoint of the two touch points
    CGFloat midpoint = (_initialTouchPoints.upper.y + _initialTouchPoints.lower.y) / 2;
    CGPoint upperPoint = CGPointMake(_initialTouchPoints.upper.x, midpoint - (_tableView.rowHeight / 2));
    CGPoint lowerPoint = CGPointMake(_initialTouchPoints.lower.x, midpoint + (_tableView.rowHeight / 2));

    // Locate the cells that these points fall within
    _pointOneCellIndex = -100;
    _pointTwoCellIndex = -100;

    NSArray *visibleCells = _tableView.visibleCells;
    for (int i = 0; i < visibleCells.count; i++)
    {
        UIView *cell = (UIView *)visibleCells[i];
        if ([self viewContainsPoint:cell withPoint:upperPoint])
        {
            _pointOneCellIndex = i;
        }
        if ([self viewContainsPoint:cell withPoint:lowerPoint])
        {
            _pointTwoCellIndex = i;
        }
    }

    // Check that these cells are neighbours
    if (abs(_pointOneCellIndex - _pointTwoCellIndex) == 1)
    {
        // Initiate the pinch gesture
        _pinchInProgress = YES;
        _pinchExceededRequiredDistance = NO;

        // Insert the placeholder cell between the two neighbouring cells
        ItemTableViewCell *precedingCell = (ItemTableViewCell *)visibleCells[_pointOneCellIndex];
        _placeholderCell.frame = CGRectOffset(precedingCell.frame, 0, 0);
        [_tableView insertSubview:_placeholderCell atIndex:0];
        
    }
}

- (void)pinchChanged:(UIPinchGestureRecognizer *)recognizer
{
    // Find the two touch points
    TouchPoints currentTouchPoints = [self getNormalisedTouchPoints:recognizer];

    // Determine by how much each touch point has changed, and take the minimum delta
    float upperDelta = MIN(currentTouchPoints.upper.y - _initialTouchPoints.upper.y, 0.0f);
    float lowerDelta = MAX(currentTouchPoints.lower.y - _initialTouchPoints.lower.y, 0.0f);

    // Move the cells, negative for the cells above, positive for those below
    NSArray *visibleCells = _tableView.visibleCells;
    for (int i = 0; i < visibleCells.count; i++)
    {
        UIView *cell = (UIView *)visibleCells[i];
        if (i <= _pointOneCellIndex)
        {
            cell.transform = CGAffineTransformMakeTranslation(0.0f, upperDelta);
        }
        if (i >= _pointTwoCellIndex)
        {
            cell.transform = CGAffineTransformMakeTranslation(0.0f, lowerDelta);
        }
    }

    // Scale the placeholder cell
    float gapSize = MAX(lowerDelta - upperDelta, 0.0f);
    float cappedGapSize = MIN(gapSize, _tableView.rowHeight);

    _placeholderCell.transform = CGAffineTransformMakeScale(1.0f, cappedGapSize / _tableView.rowHeight);

    // Maintain the location of the placeholder cell and update its contextual cues
    UIView *precedingCell = (UIView *)visibleCells[_pointOneCellIndex];
    UIView *followingCell = (UIView *)visibleCells[_pointTwoCellIndex];
    float newPosition = (precedingCell.frame.origin.y + followingCell.frame.origin.y) / 2;
    if (gapSize <= _tableView.rowHeight) newPosition += (_tableView.rowHeight - _placeholderCell.frame.size.height) / 2;
    _placeholderCell.frame = CGRectMake(0, newPosition, _placeholderCell.frame.size.width, _placeholderCell.frame.size.height);

    _placeholderCell.alpha = MIN(1.0f, gapSize / _tableView.rowHeight);

    _placeholderCell.itemLabel.text = gapSize > _tableView.rowHeight ? @"Release to Add Item" : @"Pull to Add Item";

    _placeholderCell.backgroundColor = gapSize > _tableView.rowHeight ?
        [UIColor whiteColor] : [UIColor colorWithWhite:0.5f alpha:1.0f];
//        [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];

    // Determine whether the user has pinched far enough
    _pinchExceededRequiredDistance = gapSize > _tableView.rowHeight;
}

- (void)pinchEnded:(UIPinchGestureRecognizer *)recognizer
{
    _pinchInProgress = NO;

    // Remove the placeholder cell
    _placeholderCell.transform = CGAffineTransformIdentity;
    [_placeholderCell removeFromSuperview];

    if (_pinchExceededRequiredDistance)
    {
        // Add a new item
        int indexOffset = floor(_tableView.contentOffset.y / _tableView.rowHeight);

        // Notify the table data source that a new to-do item should be inserted at the current index
        [_tableView.dataSource tableView:_tableView commitEditingStyle:UITableViewCellEditingStyleInsert
                       forRowAtIndexPath:[NSIndexPath indexPathForRow:_pointTwoCellIndex + indexOffset inSection:0]];
    }
    else
    {
        // Otherwise animate the pinched cells back to their original positions
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             NSArray *visibleCells = _tableView.visibleCells;
                             for (ItemTableViewCell *cell in visibleCells)
                             {
                                 cell.transform = CGAffineTransformIdentity;
                             }
                         }
                         completion:nil];
    }
}

#pragma mark - Utility Methods

// Utility method to return the two touch points of a pinch gesture,
// ordering them to ensure that upper and lower are correctly identified
- (TouchPoints) getNormalisedTouchPoints:(UIGestureRecognizer *)recognizer
{
    // Get the two touch points
    CGPoint pointOne = [recognizer locationOfTouch:0 inView:_tableView];
    CGPoint pointTwo = [recognizer locationOfTouch:1 inView:_tableView];

    // Ensure pointOne is the topmost; if not, swap them
    if (pointOne.y > pointTwo.y)
    {
        CGPoint temp = pointOne;
        pointOne = pointTwo;
        pointTwo = temp;
    }

    TouchPoints points = {pointOne, pointTwo};
    return points;
}

- (BOOL)viewContainsPoint:(UIView *)view withPoint:(CGPoint)point
{
    CGRect frame = view.frame;
    return (frame.origin.y < point.y) && (frame.origin.y + frame.size.height) > point.y;
}

@end
