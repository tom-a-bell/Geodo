//
//  ListTableViewController.h
//  Geodo
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ListTableViewControllerDelegate.h"
#import "TableViewDragToReveal.h"

@interface ListTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

// The view controller that acts as delegate for this controller
@property (nonatomic, assign) id<ListTableViewControllerDelegate> delegate;

// The slide-from-edge gesture controller
@property (weak, nonatomic) TableViewDragToReveal *slideToRevealController;

// Properties of the Core Data stack
@property (strong, nonatomic) NSFetchedResultsController *listFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *placeFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)selectDefaultList;
- (void)selectList:(ToDoList *)list;
- (void)setSlideToRevealController:(TableViewDragToReveal *)slideToRevealController;

@end
