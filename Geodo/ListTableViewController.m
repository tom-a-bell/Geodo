//
//  ListTableViewController.m
//  Geodo
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListTableViewCell.h"
#import "TableViewCell.h"

#import "TableViewPressToMove.h"

#import "ToDoList.h"
#import "Place.h"

@implementation ListTableViewController
{
    // Press-to-move gesture controller
    TableViewPressToMove *_pressToMove;

    // Store the currently selected row index
    NSIndexPath *_selectedIndex;

    // Array of date range views
    NSArray *_dateOptions;
}

static NSString *ListCellIdentifier = @"ListCell";
static NSString *DateCellIdentifier = @"DateCell";
static NSString *PlaceCellIdentifier = @"PlaceCell";

- (id)initWithStyle:(UITableViewStyle)style managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
    self = [super initWithStyle:style];

    if (self)
    {
        self.managedObjectContext = managedObjectContext;

        // Specify the default date range options
        _dateOptions = [[NSArray alloc] initWithObjects:@"Today", @"Upcoming", @"This Week", nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:ListCellIdentifier];
    [self.tableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:DateCellIdentifier];
    [self.tableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:PlaceCellIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];

    // Preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;

    if (![self.tableView indexPathForSelectedRow])
    {
        [self selectDefaultList];
    }

    // Register the press-to-move gesture with the table view and specify the delegate
    _pressToMove = [[TableViewPressToMove alloc] initWithTableView:self.tableView];
    _pressToMove.delegate = self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Toggle the editing mode of the table view
    [super setEditing:editing animated:animated];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.listFetchedResultsController sections][0];
        return [sectionInfo numberOfObjects];
    }
    if (section == 1)
    {
        return [_dateOptions count];
    }
    if (section == 2)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.placeFetchedResultsController sections][0];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = nil;

    // Re-use or create a cell
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];
    }
    if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:DateCellIdentifier forIndexPath:indexPath];
    }
    if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceCellIdentifier forIndexPath:indexPath];
    }

    // Configure the cell properties
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Lists";
    }
    if (section == 1)
    {
        return @"Deadlines";
    }
    if (section == 2)
    {
        return @"Locations";
    }
    if (section == 3)
    {
        return @"Settings";
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert)
//    {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ToDoList *list = [self.listFetchedResultsController objectAtIndexPath:sourceIndexPath];
    [self insertList:list atIndexPath:destinationIndexPath];
}

#pragma mark - UITableViewDelegate Protocol Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;

    // Set the properties of the header view
    headerView.textLabel.textColor = [UIColor whiteColor];
    headerView.textLabel.textAlignment = NSTextAlignmentCenter;
    headerView.contentView.backgroundColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Store the newly selected row index
    _selectedIndex = indexPath;

    // Retrieve the selected cell
    ListTableViewCell *cell = (ListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    // Notify the delegate that the to-do list has been selected
    if (indexPath.section == 0)
    {
        [self.delegate toDoListSelected:cell.todoList];
    }
    if (indexPath.section == 1)
    {
        [self.delegate dateRangeSelected:(indexPath.row + 1)];
    }
    if (indexPath.section == 2)
    {
        [self.delegate locationSelected:cell.place];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)listFetchedResultsController
{
    if (_listFetchedResultsController)
    {
        return _listFetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ToDoList"];

    // Set the batch size to fetch enough items to fill the table's content view
    [fetchRequest setFetchBatchSize:20];

    // Sort the lists by index
    NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByIndex]];

    _listFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil cacheName:nil];
    _listFetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![self.listFetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _listFetchedResultsController;
}

- (NSFetchedResultsController *)placeFetchedResultsController
{
    if (_placeFetchedResultsController)
    {
        return _placeFetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];

    // Set the batch size to fetch enough items to fill the table's content view
    [fetchRequest setFetchBatchSize:10];

    // Include only favourite locations
    NSPredicate *favouritePlaces = [NSPredicate predicateWithFormat:@"name.length > 0 and favourite == YES"];
    [fetchRequest setPredicate:favouritePlaces];

    // Sort the places by creation date
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByDate]];

    _placeFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil cacheName:nil];
    _placeFetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![self.placeFetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _placeFetchedResultsController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.itemTableView;
//
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:(TableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:_selectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Utility Methods

- (void)configureCell:(ListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // Fetch the appropriate to-do list
        ToDoList *list = [self.listFetchedResultsController objectAtIndexPath:indexPath];

        // Specify the to-do list
        [cell setTodoList:list];
    }
    if (indexPath.section == 1)
    {
        // Specify the date range
        [cell setDateRange:[_dateOptions objectAtIndex:indexPath.row]];
    }
    if (indexPath.section == 2)
    {
        // Create a new index path for the same row, but in section 0
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];

        // Fetch the appropriate place
        Place *place = [self.placeFetchedResultsController objectAtIndexPath:indexPath];

        // Specify the place
        [cell setPlace:place];
    }
}

- (void)selectDefaultList
{
    ToDoList *defaultList = [[self.listFetchedResultsController fetchedObjects] firstObject];
    [self selectList:defaultList];
}

- (void)selectList:(ToDoList *)list
{
    if (!list)
    {
        [self selectDefaultList];
        return;
    }

    NSIndexPath *indexPath = [self.listFetchedResultsController indexPathForObject:list];

    _selectedIndex = indexPath;

    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.delegate toDoListSelected:list];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    // Create a default set of to-do lists
    if ([[self.listFetchedResultsController sections] count] == 0 || [[self.listFetchedResultsController sections][0] numberOfObjects] == 0)
    {
        NSLog(@"Adding default to-do lists...");

        ToDoList *all = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
        all.index = 0;
        all.name = @"All Items";
        all.color = [UIColor colorWithRed:0.6f green:0.0f blue:0.501961f alpha:1.0f];

        ToDoList *home = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
        home.index = 1;
        home.name = @"Home";
        home.color = [UIColor colorWithRed:0.168627f green:0.360784f blue:0.8f alpha:1.0f];

        ToDoList *work = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
        work.index = 2;
        work.name = @"Work";
        work.color = [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f];

        ToDoList *chores = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
        chores.index = 3;
        chores.name = @"Chores";
        chores.color = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f];

        ToDoList *travel = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
        travel.index = 4;
        travel.name = @"Travel";
        travel.color = [UIColor colorWithRed:1.0f green:0.701961f blue:0.0f alpha:1.0f];

        [self saveContext];

        NSLog(@"...default to-do lists saved!");
    }
}

- (void)setSlideToRevealController:(TableViewDragToReveal *)slideToRevealController
{
    _slideToRevealController = slideToRevealController;

    // Add the pan gesture recognizer for use with the slide-to-reveal gesture controller
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.slideToRevealController
                                                                                 action:@selector(handlePan:)];
    recognizer.delegate = self.slideToRevealController;
    [self.tableView addGestureRecognizer:recognizer];
}

- (void)insertList:(ToDoList *)insertedList atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 0;
    for (ToDoList *currentList in [self.listFetchedResultsController fetchedObjects])
    {
        if (index == indexPath.row) index++;

        if (currentList == insertedList)
        {
            currentList.index = indexPath.row;
        }
        else
        {
            currentList.index = index++;
        }
    }
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
