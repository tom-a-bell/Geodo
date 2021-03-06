//
//  TableViewPinchToAdd.h
//  Geodo
//
//  A behavior that adds the ability to pinch apart any two rows
//  in a UITableView in order to insert a new item between them.
//
//  Created by Tom Bell on 27/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewPinchToAdd : NSObject

// The object that acts as the table view delegate
@property (nonatomic, assign) id<UITableViewDelegate> delegate;

// Associates this behavior with the given table
- (id)initWithTableView:(UITableView *)tableView;

@end
