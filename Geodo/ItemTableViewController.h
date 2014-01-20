//
//  ViewController.h
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "PlaceholderCellDelegate.h"
#import "ItemTableViewCellDelegate.h"
#import "ListTableViewControllerDelegate.h"
#import "TableViewDragToRevealDelegate.h"

@class ListTableViewController;

@interface ItemTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,
                                                      ItemTableViewCellDelegate, PlaceholderCellDelegate, ListTableViewControllerDelegate,
                                                      TableViewDragToRevealDelegate>
{
    // Controller for the list table view
    ListTableViewController *listController;
}

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
