//
//  TableViewDragToAdd.m
//  ClearStyle
//
//  Created by Tom Bell on 27/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "TableViewDragToAdd.h"
#import "ItemTableViewCell.h"

@implementation TableViewDragToAdd
{
    // The table view that this class extends and adds behavior to
    UITableView *_tableView;

    // Placeholder cell to indicate where a new item is to be added
    ItemTableViewCell *_placeholderCell;

    // Indicates the current state of the gesture
    BOOL _pullDownInProgress;

    // Indicates that the pull down was big enough to cause a new item to be added
    BOOL _pullDownExceededRequiredDistance;
}

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        // Create the placeholder cell to use for “pull to add” gestures
        _placeholderCell = [[ItemTableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor whiteColor];
//        _placeholderCell.backgroundColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
        _placeholderCell.itemLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderCell.editButton.hidden = YES;

        _tableView = tableView;
        _tableView.delegate = self;
    }
    return self;
}

#pragma mark - UITableViewDelegate Protocol Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
    {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Add the placeholder cell
    [_tableView insertSubview:_placeholderCell atIndex:0];

//    // This behaviour starts when the user pulls down while at the top of the table
//    _pullDownInProgress = _tableView.contentOffset.y <= 0.0f;
//
//    if (_pullDownInProgress)
//    {
//        // Add the placeholder cell
//        [_tableView insertSubview:_placeholderCell atIndex:0];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    if (_pullDownInProgress && _tableView.contentOffset.y <= 0.0f)
    if (_tableView.contentOffset.y <= 0.0f)
    {
        // This behaviour starts when the user drags down beyond the top of the table
        _pullDownInProgress = YES;

        // Maintain the location of the placeholder cell and update its contextual cues
        _placeholderCell.frame = CGRectMake(0, -_tableView.rowHeight, _tableView.frame.size.width, _tableView.rowHeight);

        _placeholderCell.alpha = MIN(1.0f, -_tableView.contentOffset.y / _tableView.rowHeight);

        _placeholderCell.itemLabel.text = -_tableView.contentOffset.y > _tableView.rowHeight ?
            @"Release to Add Item" : @"Pull to Add Item";

        _placeholderCell.backgroundColor = -_tableView.contentOffset.y > _tableView.rowHeight ?
            [UIColor whiteColor] : [UIColor colorWithWhite:0.5f alpha:1.0f];
//            [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];

        // Determine whether the user has pulled down far enough
        _pullDownExceededRequiredDistance = -_tableView.contentOffset.y > _tableView.rowHeight;
    }
    else
    {
        _pullDownInProgress = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Check whether the user pulled down far enough to add a new item
    if (_pullDownInProgress && -_tableView.contentOffset.y > _tableView.rowHeight)
    {
        // Notify the table data source that a new to-do item should be inserted at the top of the table
        [_tableView.dataSource tableView:_tableView commitEditingStyle:UITableViewCellEditingStyleInsert
                       forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }

    // Remove the placeholder cell
    [_placeholderCell removeFromSuperview];

    _pullDownInProgress = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

@end
