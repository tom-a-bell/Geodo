//
//  ListViewController.m
//  ClearStyle
//
//  Created by Tom Bell on 12/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ListViewController.h"
#import "EditListViewController.h"
#import "NavigationController.h"

#import "ToDoList.h"
#import "Place.h"

@implementation ListViewController

static NSString *ListCellIdentifier = @"ListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Retrieve the managed object context from the navigation controller
    NavigationController *navigationController = (NavigationController *)[self navigationController];
    self.managedObjectContext = navigationController.managedObjectContext;

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor darkTextColor], NSForegroundColorAttributeName,
                                    [UIColor darkTextColor], NSBackgroundColorAttributeName, nil];

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];);

    // Edit behaviour depends on whether the view controller is passed a to-do item
    if (self.todoItem)
    {
        // Create the Edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else
    {
        self.title = @"Edit Lists";
        [self setEditing:YES animated:NO];
        [self.navigationItem setHidesBackButton:YES animated:NO];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // Toggle the editing mode of the table view
    [super setEditing:editing animated:animated];

    if (editing)
    {
        // Create and display the Add button
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self action:@selector(addList)];
        [self.navigationItem setLeftBarButtonItem:addButton animated:YES];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Re-use or create a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier forIndexPath:indexPath];

    // Configure the cell properties
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row != 0;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row != 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToDoList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the list from the managed object context
        [self.managedObjectContext deleteObject:list];
        [self saveContext];
    }

//    if (editingStyle == UITableViewCellEditingStyleInsert)
//    {
//        // Insert a new list at the specified index path
//        [self insertNewListAtIndexPath:indexPath];
//    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ToDoList *list = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    [self insertList:list atIndexPath:destinationIndexPath];
}

#pragma mark - UITableViewDelegate Protocol Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.todoItem.list = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueToEditListView" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
    {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ToDoList"];

    // Set the batch size to fetch enough items to fill the table's content view
    [fetchRequest setFetchBatchSize:20];

    // Sort the lists by index
    NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByIndex]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:(UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - View Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set up the edit list view controller properties
    if ([segue.identifier isEqualToString:@"segueToEditListView"])
    {
        EditListViewController *viewController = [segue destinationViewController];

        // Specify the list
        viewController.todoList = sender;
    }
}

- (IBAction)updateList:(UIStoryboardSegue *)segue
{
    [self saveContext];
    [self.tableView reloadData];
}

#pragma mark - Utility Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // Fetch the appropriate to-do list
    ToDoList *list = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Specify the cell title and colour
    cell.textLabel.text = list.name;
    cell.textLabel.textColor = list.color;
    cell.detailTextLabel.text = list.place ? [NSString stringWithFormat:@"Location: %@", [list.place name]] : @"";
//    cell.tintColor = self.tableView.isEditing? nil : list.color;
    cell.accessoryType = list == self.todoItem.list ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.editingAccessoryType = UITableViewCellAccessoryDetailButton;
}

- (void)addList
{
    // Create the new to-do list at the bottom of the table
    ToDoList *list = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
    list.index = [[[self.fetchedResultsController fetchedObjects] lastObject] index] + 1;
    list.name = @"New List";

    // Select the new list
    [self.tableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:list] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)insertList:(ToDoList *)insertedList atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 0;
    for (ToDoList *currentList in [self.fetchedResultsController fetchedObjects])
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
