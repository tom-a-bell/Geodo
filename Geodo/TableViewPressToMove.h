//
//  TableViewPressToMove.h
//  Geodo
//
//  A behavior that adds the ability to long-press on a row
//  in a UITableView in order to rearrange its position.
//
//  Created by Tom Bell on 01/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewPressToMove : NSObject

// The object that acts as the table view delegate
@property (nonatomic, assign) id<UITableViewDataSource> delegate;

// Associates this behavior with the given table
- (id)initWithTableView:(UITableView *)tableView;

@end
