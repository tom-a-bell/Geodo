//
//  TableViewSwipeToReveal.h
//  ClearStyle
//
//  A behavior that adds the ability to swipe from the left edge
//  of a UITableView in order to reveal a hidden view behind it.
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewDragToRevealDelegate.h"

@interface TableViewDragToReveal : NSObject <UIGestureRecognizerDelegate>

// The object that acts as the delegate
@property (nonatomic, assign) id<TableViewDragToRevealDelegate> delegate;

// Associates this behavior with the given table
- (id)initWithTableView:(UITableView *)tableView;

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)recognizer;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
