//
//  TableViewDragToRevealDelegate.h
//  ClearStyle
//
//  Created by Tom Bell on 24/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

// Protocol used by TableViewDragToReveal to inform of state changes
@protocol TableViewDragToRevealDelegate <NSObject>

@optional

// Indicates that the given view is now visible
- (void)didRevealView:(UIView *)view;

// Indicates that the given view is now hidden
- (void)didHideView:(UIView *)view;

@end
