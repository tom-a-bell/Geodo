//
//  ListViewController.h
//  Geodo
//
//  Created by Tom Bell on 12/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface ListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

// The to-do item passed to and from this view
@property (nonatomic) ToDoItem *todoItem;

// Properties of the Core Data stack
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
