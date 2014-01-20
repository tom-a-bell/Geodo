//
//  TableViewSwipeToReveal.m
//  ClearStyle
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "TableViewDragToReveal.h"

@implementation TableViewDragToReveal
{
    // The table view that this class extends and adds behavior to
    UITableView *_tableView;

    // Stores the original location and frame of the table view
    CGPoint _originalCenter;
    CGRect _originalFrame;

    // Indicates the current state of the gesture
    BOOL _swipeInProgress;

    // Indicates that the drag was far enough to prevent the table view from snapping back
    BOOL _swipeExceededRequiredDistance;
}

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];

    if (self)
    {
        _tableView = tableView;

        // Add the drag recognizers (UIScreenEdgePanGestureRecognizer only available in iOS7 and above)
        IF_IOS7_OR_GREATER(
        UIScreenEdgePanGestureRecognizer *edgeRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
        edgeRecognizer.edges = UIRectEdgeLeft;
        [_tableView addGestureRecognizer:edgeRecognizer];
        );

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.delegate = self;
        [_tableView addGestureRecognizer:panRecognizer];
    }

    return self;
}

#pragma mark - Pan Gesture Methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Check for gestures other than the pan gesture
    if ([gestureRecognizer class] != [UIPanGestureRecognizer class])
    {
        return NO;
    }

    CGPoint location =[gestureRecognizer locationInView:[_tableView superview]];

    // Check that the gesture was started near the edge of the table view
    if (fabsf(location.x - _tableView.frame.origin.x) >  25)
    {
        return NO;
    }

    CGPoint translation = [gestureRecognizer translationInView:[_tableView superview]];

    // Check for a horizontal leftward gesture when the background view has been revealed
    if (_swipeExceededRequiredDistance && fabsf(translation.x) > fabsf(translation.y) && translation.x < 0)
    {
        return YES;
    }

    // Check for a horizontal rightware gesture from the screen edge when the background view is hidden
    IF_PRE_IOS7(
    if (!_swipeExceededRequiredDistance && location.x <= 15 && fabsf(translation.x) > fabsf(translation.y) && translation.x > 0)
    {
        return YES;
    }
    );

    return NO;
}

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    // Step 1
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // If the gesture has just started, record the current centre location and frame of the table view
        _originalCenter = _tableView.center;
        _originalFrame = _tableView.frame;
    }

    // Step 2
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Translate the center horizontally
        CGPoint translation = [recognizer translationInView:_tableView];
        _tableView.center = CGPointMake(_originalCenter.x + MIN(translation.x, 120.0f), _originalCenter.y);

        // Determine whether the view has been dragged far enough to the right to prevent it snapping back
        _swipeExceededRequiredDistance = _tableView.frame.origin.x >= 80.0f;
    }

    // Step 3
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // If the view has been dragged far enough to the right, move it to the fully revealed position
        if (_swipeExceededRequiredDistance)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect revealedFrame = CGRectMake(_originalFrame.origin.x + 120.0f, _originalFrame.origin.y, _originalFrame.size.width, _originalFrame.size.height);
                _tableView.frame = revealedFrame;
            }];

            // Notify the delegate that the view has been revealed
            [self.delegate didRevealView:_tableView];
        }
        // Otherwise, snap back to the original location
        if (!_swipeExceededRequiredDistance)
        {
            [UIView animateWithDuration:0.2 animations:^{
                _tableView.frame = _originalFrame;
            }];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // Step 1
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // If the gesture has just started, record the current centre location and frame of the table view
        if (!_swipeExceededRequiredDistance)
        {
            _originalCenter = _tableView.center;
            _originalFrame = _tableView.frame;
        }
    }

    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Translate the center horizontally
        CGPoint translation = [recognizer translationInView:_tableView];

        // Leftward gesture
        if (translation.x > 0)
        {
            _tableView.center = CGPointMake(_originalCenter.x + MIN(translation.x, 120.0f), _originalCenter.y);
        }
        // Rightward gesture
        else
        {
            _tableView.center = CGPointMake(_originalCenter.x + 120.f + MAX(translation.x, -120.0f), _originalCenter.y);
        }

        // Determine whether the view has been dragged far enough to the right to prevent it snapping back
        _swipeExceededRequiredDistance = _tableView.frame.origin.x >= 80.0f;
    }

    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // If the view has not been dragged far enough to the left, return to the revealed position
        if (_swipeExceededRequiredDistance)
        {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect revealedFrame = CGRectMake(_originalFrame.origin.x + 120.0f, _originalFrame.origin.y, _originalFrame.size.width, _originalFrame.size.height);
                _tableView.frame = revealedFrame;
            }];

            // Notify the delegate that the view has been revealed
            [self.delegate didRevealView:_tableView];
        }
        // Otherwise, snap back to the original location
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                _tableView.frame = _originalFrame;
            }];

            // Notify the delegate that the view has been hidden
            [self.delegate didHideView:_tableView];
        }
    }
}

@end
