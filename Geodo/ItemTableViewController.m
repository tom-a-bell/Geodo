//
//  ViewController.m
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ItemTableViewController.h"
#import "ListTableViewController.h"
#import "EditItemViewController.h"

#import "PlaceholderCell.h"
#import "DemoTableViewCell.h"
#import "ItemTableViewCell.h"
#import "ListTableViewCell.h"

#import "TableViewDragToAdd.h"
#import "TableViewPinchToAdd.h"
#import "TableViewPressToMove.h"
#import "TableViewDragToReveal.h"

#import "ToDoItem.h"
#import "ToDoList.h"
#import "Place.h"

#import "LocationHandler.h"

@implementation ItemTableViewController
{
    // Store the currently selected to-do list
    ToDoList *_currentList;

    // Store the currently selected date range
    NSInteger _currentDate;

    // Store the currently selected location
    Place *_currentPlace;

    // Completed items view state
    BOOL _completedItems;

    // Slide-from-edge gesture controller
    TableViewDragToReveal *_slideToReveal;

    // Drag-to-add gesture controller
    TableViewDragToAdd *_pullToAdd;

    // Pinch-to-add gesture controller
    TableViewPinchToAdd *_pinchToAdd;

    // Press-to-move gesture controller
    TableViewPressToMove *_pressToMove;

    // Current cell being edited
    UITableViewCell *_editingCell;

    // Content offset when entering “edit mode”
    CGPoint _previousOffset;
}

static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
static NSString *DemoItemCellIdentifier = @"DemoItemCell";

static NSString *ItemCellIdentifier = @"ItemCell";
static NSString *ListCellIdentifier = @"ListCell";
static NSString *DateCellIdentifier = @"DateCell";
static NSString *PlaceCellIdentifier= @"PlaceCell";

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }

    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Instantiate and set up the to-do list table view controller
    if (!listController)
    {
        listController = [[ListTableViewController alloc] initWithStyle:UITableViewStylePlain managedObjectContext:self.managedObjectContext];
        listController.managedObjectContext = self.managedObjectContext;
        listController.tableView = self.listTableView;
        listController.delegate = self;
    }

    // Create a default set of to-do lists
    if ([[self.fetchedResultsController sections] count] == 0 || [[self.fetchedResultsController sections][0] numberOfObjects] == 0)
    {
        NSLog(@"Adding default to-do items...");
        [self createDefaultItems];
        NSLog(@"...default to-do items saved!");
    }

    [self.itemTableView registerClass:[PlaceholderCell class] forCellReuseIdentifier:PlaceholderCellIdentifier];
    [self.itemTableView registerClass:[DemoTableViewCell class] forCellReuseIdentifier:DemoItemCellIdentifier];
    [self.itemTableView registerClass:[ItemTableViewCell class] forCellReuseIdentifier:ItemCellIdentifier];
    [self.itemTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.itemTableView setBackgroundColor:[UIColor blackColor]];
    [self.itemTableView setDataSource:self];
    [self.itemTableView setDelegate:self];

    [self.listTableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:ListCellIdentifier];
    [self.listTableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:DateCellIdentifier];
    [self.listTableView registerClass:[ListTableViewCell class] forCellReuseIdentifier:PlaceCellIdentifier];
    [self.listTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.listTableView setBackgroundColor:[UIColor blackColor]];
    [self.listTableView setDataSource:listController];
    [self.listTableView setDelegate:listController];

    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor lightTextColor], NSForegroundColorAttributeName,
                                    [UIColor lightTextColor], NSBackgroundColorAttributeName, nil];

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.3 alpha:1.0];);
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;

    // Create and display the "show completed items" button
    IF_IOS7_OR_GREATER(
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor lightTextColor], UITextAttributeTextColor,
                          [UIFont fontWithName:@"FontAwesome" size:16], UITextAttributeFont, nil];
    );

    IF_PRE_IOS7(
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont fontWithName:@"FontAwesome" size:16], UITextAttributeFont, nil];
    );

    _completedItems = NO;
    UIBarButtonItem *completedButton = [[UIBarButtonItem alloc] initWithTitle:@"\uf00c" style:UIBarButtonItemStyleBordered target:self action:nil];
    [completedButton setAction:@selector(showCompletedItems)];
    [completedButton setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:completedButton animated:YES];

    if (_currentList)
    {
        self.title = _currentList.name;
        IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = _currentList.color;);
    }
    else
    {
        [listController selectDefaultList];
    }

    // Register the drag-from-edge gesture with the table view and specify the delegate
    _slideToReveal = [[TableViewDragToReveal alloc] initWithTableView:self.itemTableView];
    _slideToReveal.delegate = self;

    // Register the drag-to-add gesture with the table view and specify the delegate
    _pullToAdd = [[TableViewDragToAdd alloc] initWithTableView:self.itemTableView];
    _pullToAdd.delegate = self;

    // Register the pinch-to-add gesture with the table view and specify the delegate
    _pinchToAdd = [[TableViewPinchToAdd alloc] initWithTableView:self.itemTableView];
    _pinchToAdd.delegate = self;

    // Register the press-to-move gesture with the table view and specify the delegate
    _pressToMove = [[TableViewPressToMove alloc] initWithTableView:self.itemTableView];
    _pressToMove.delegate = self;

    // Register the drag-from-edge gesture with the to-do list table view controller
    [listController setSlideToRevealController:_slideToReveal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_currentList)
    {
        [self toDoListSelected:_currentList];
    }
    else if(_currentPlace)
    {
        [self locationSelected:_currentPlace];
    }
    else
    {
        [self dateRangeSelected:_currentDate];
    }
    [self.itemTableView reloadData];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    if (section == 0 && !_completedItems)
    {
        return [sectionInfo numberOfObjects] + 1;
    }
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.fetchedResultsController.fetchedObjects.count)
    {
        // Re-use or create a placeholder cell
        PlaceholderCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];

        // Configure the cell properties
        [self configureCell:cell atIndexPath:indexPath];

        return cell;
    }

    if ([[[self.fetchedResultsController objectAtIndexPath:indexPath] reference] hasPrefix:@"IntroItem"])
    {
        // Re-use or create a placeholder cell
        DemoTableViewCell *cell = [[DemoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DemoItemCellIdentifier];
//        DemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DemoItemCellIdentifier forIndexPath:indexPath];

        // Configure the cell properties
        [self configureCell:cell atIndexPath:indexPath];

        return cell;
    }

    // Re-use or create a cell
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ItemCellIdentifier forIndexPath:indexPath];

    // Configure the cell properties
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    IF_PRE_IOS7([cell setBackgroundColor:[UIColor clearColor]];);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Insert a new to-do item at the requested row in the table
    if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new to-do item and insert it at the specified index
        ToDoItem *item = [self newItem];
        [self insertItem:item atIndexPath:indexPath];

        // Refresh the table view
        [self.itemTableView reloadData];

        // Locate the cell that renders the newly added to-do item
        ItemTableViewCell *editingCell;
        for (ItemTableViewCell *cell in [self.itemTableView visibleCells])
        {
            if ([cell isKindOfClass:[ItemTableViewCell class]] && cell.todoItem == item)
            {
                editingCell = cell;
                break;
            }
        }
        
        // Enter editing mode
        [editingCell.itemLabel becomeFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ToDoItem *item = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    [self insertItem:item atIndexPath:destinationIndexPath];
}

#pragma mark - UITableViewDelegate Protocol Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark - TableViewCellDelegate Protocol Methods

- (void)cellDidBeginEditing:(UITableViewCell *)editingCell
{
    // Store the selected cell
    _editingCell = editingCell;

    // Store the current offset of the selected cell within the table view
    _previousOffset = self.itemTableView.contentOffset;

    // Determine the new offset to position the cell at the top of the table view
    NSIndexPath *indexPath = nil;
    if ([editingCell isKindOfClass:[ItemTableViewCell class]])
    {
        indexPath = [self.fetchedResultsController indexPathForObject:[(ItemTableViewCell *)editingCell todoItem]];
    }
    else if ([editingCell isKindOfClass:[PlaceholderCell class]])
    {
        indexPath = [self.fetchedResultsController indexPathForObject:self.fetchedResultsController.fetchedObjects.lastObject];
        indexPath = [NSIndexPath indexPathForRow:(indexPath.row+1) inSection:indexPath.section];
    }
    CGPoint newOffset = CGPointMake(_previousOffset.x, editingCell.frame.size.height * indexPath.row);

    // Scroll the selected cell to the top of the table view
    [self.itemTableView setContentOffset:newOffset animated:YES];

    // Trigger the end of scrolling animation manually if at the top of the table view
    if (indexPath.row == 0) [self scrollViewDidEndScrollingAnimation:self.itemTableView];
}

- (void)cellDidEndEditing:(UITableViewCell *)editingCell
{
    [self saveContext];

    // Reset the editing cell
    _editingCell = nil;

    // Iterate over all visible cells
    for (UITableViewCell *cell in [self.itemTableView visibleCells])
    {
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 1.0;
        }];
    }

    // Scroll the selected call back to its original position in the table view
    [self.itemTableView setContentOffset:_previousOffset animated:YES];
}

- (void)markAsCompleted:(ToDoItem *)item
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:item];

    // Mark already completed items as not completed and clear their due date
    if (item.completed)
    {
        item.completed = NO;
        item.dueDate = nil;
    }
    else
    {
        item.completed = YES;
        item.dueDate = [NSDate date];
    }

    // Stop monitoring the place associated with this item
    [[LocationHandler sharedInstance] stopMonitoringForItem:item];

    // Cancel any due date notifications associated with this item
    [item cancelScheduledNotifications];

    [self saveContext];

    // Animate the removal of the row
    [self.itemTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];

//    // Find all visible cells
//    NSArray* visibleCells = [self.itemTableView visibleCells];
//
//    UIView* lastView = [visibleCells lastObject];
//    BOOL startAnimating = NO;
//    float delay = 0.0;
//
//    // Iterate over all visible cells
//    for (TableViewCell *cell in visibleCells)
//    {
//        if (startAnimating)
//        {
//            [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut
//                             animations:^{cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);}
//                             completion:^(BOOL finished){if (cell == lastView) {[self.itemTableView reloadData];}}];
//            delay += 0.03;
//        }
//
//        // If the deleted item has been reached, start animating
//        if ([cell isKindOfClass:[TableViewCell class]] && cell.todoItem == item)
//        {
//            startAnimating = YES;
//            cell.hidden = YES;
//        }
//    }
//
//    // Animate the insertion of the completed cell at the bottom of the table
//    UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(_toDoItems.count - 1) inSection:0]];
//    CGRect lastFrame = lastCell.frame;
//
//    TableViewCell *newCell = [[TableViewCell alloc] init];
//    [newCell setTodoItem:[_toDoItems lastObject]];
//    [newCell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
//    [newCell setFrame:lastFrame];
//    [newCell setAlpha:0.0f];
//    [self.tableView insertSubview:newCell atIndex:0];
//
//    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{[newCell setAlpha:1.0f];}
//                     completion:^(BOOL finished){[self.tableView reloadData]; [newCell removeFromSuperview];}];
}

- (void)deleteItem:(id)item
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:item];

    // Stop monitoring the place associated with this item
    LocationHandler *locationHandler = [LocationHandler sharedInstance];
    [locationHandler stopMonitoringForItem:item];

    // Cancel any due date notifications associated with this item
    [item cancelScheduledNotifications];

    // Delete the item from the managed object context
    [self.managedObjectContext deleteObject:item];
    [self saveContext];

    // Animate the removal of the row
    [self.itemTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)editToDoItem:(id)todoItem
{
    [self performSegueWithIdentifier: @"segueToEditView" sender:todoItem];
}

#pragma mark - PlaceholderCellDelegate Protocol Methods

- (void)addItemFromPlaceholderCell:(PlaceholderCell *)cell
{
    // If a non-empty description was entered, create a new to-do item and add it to the bottom of the list
    if (![cell.itemLabel.text isEqualToString:@""])
    {
        ToDoItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];

        // Set the default properties and assign a unique identifier
        item.reference = [[NSUUID UUID] UUIDString];
        item.index = [[[self.fetchedResultsController fetchedObjects] lastObject] index] + 1;
        item.text = cell.itemLabel.text;

        // Associate the item with the current list
        item.list = _currentList;

        // Save the new item
        [self saveContext];
    }

    // Reset the editing cell
    _editingCell = nil;

    // Iterate over all visible cells
    for (UITableViewCell *cell in [self.itemTableView visibleCells])
    {
        [UIView animateWithDuration:0.1f animations:^{
            cell.alpha = 1.0;
        }];
    }

    // Scroll the selected call back to its original position in the table view
    [self.itemTableView setContentOffset:_previousOffset animated:YES];

    // Refresh the table view after a delay
    SEL selector = @selector(reloadData);
    [self performSelector:selector withObject:nil afterDelay:0.3f];
}

#pragma mark - ListTableViewControllerDelegate Protocol Methods

- (void)toDoListSelected:(ToDoList *)list
{
    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor lightTextColor], NSForegroundColorAttributeName,
                                    [UIColor lightTextColor], NSBackgroundColorAttributeName, nil];

    self.title = list.name;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = list.color;);
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    // Return if the list is the same as the current list
    if (list == _currentList) return;

    _currentList = list;
    _currentPlace = nil;
    _currentDate = 0;

    // Instantiate a new fetched results controller and reload the table data
    self.fetchedResultsController = nil;
    [self.itemTableView reloadData];
}

- (void)dateRangeSelected:(NSInteger)dateRange
{
    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor lightTextColor], NSForegroundColorAttributeName,
                                    [UIColor lightTextColor], NSBackgroundColorAttributeName, nil];

    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];);
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    switch (dateRange)
    {
        case 1:
            self.title = @"Today";
            break;

        case 2:
            self.title = @"Upcoming";
            break;

        case 3:
            self.title = @"This Week";
            break;

        default:
            break;
    }

    // Return if the date range is the same as the current date range
    if (dateRange == _currentDate) return;

    _currentList = nil;
    _currentPlace = nil;
    _currentDate = dateRange;

    // Instantiate a new fetched results controller and reload the table data
    self.fetchedResultsController = nil;
    [self.itemTableView reloadData];
}

- (void)locationSelected:(Place *)place
{
    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor lightTextColor], NSForegroundColorAttributeName,
                                    [UIColor lightTextColor], NSBackgroundColorAttributeName, nil];

    self.title = place.name;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];);
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    // Return if the location is the same as the current place
    if (place == _currentPlace) return;

    _currentList = nil;
    _currentPlace = place;
    _currentDate = 0;

    // Instantiate a new fetched results controller and reload the table data
    self.fetchedResultsController = nil;
    [self.itemTableView reloadData];
}

#pragma mark - TableViewDragToRevealDelegate Protocol Methods

- (void)didRevealView:(UIView *)view
{
    // Create and display the Edit button
    NSDictionary *textAttributes = nil;
    IF_IOS7_OR_GREATER(
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor lightTextColor], UITextAttributeTextColor,
                          [UIFont systemFontOfSize:16], UITextAttributeFont, nil];
    );

    IF_PRE_IOS7(
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont systemFontOfSize:16], UITextAttributeFont, nil];
    );
    
//    UIBarButtonItem *editButton = listController.editButtonItem;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:nil];
    [editButton setAction:@selector(showEditListView)];
    [editButton setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:editButton animated:YES];
}


- (void)didHideView:(UIView *)view
{
    // Remove the Edit button
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!_editingCell) return;

    // Iterate over all visible cells
    for (UITableViewCell *cell in [self.itemTableView visibleCells])
    {
        [UIView animateWithDuration:0.0 animations:^{
            if (cell == _editingCell)
            {
                cell.alpha = 1.0;
            }
            else
            {
                cell.alpha = 0.3;
            }
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
    {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ToDoItem"];

    // Set the batch size to fetch enough items to fill the table's content view
    [fetchRequest setFetchBatchSize:20];

    if ([_currentList.name isEqualToString:@"All Items"])
    {
        // Include only the items that match the current view completed status
        NSPredicate *allListItems = [NSPredicate predicateWithFormat:@"completed == %@", [NSNumber numberWithBool:_completedItems]];
        [fetchRequest setPredicate:allListItems];

        // Sort the items by list, then by index
        NSSortDescriptor *sortByCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
        NSSortDescriptor *sortByList  = [[NSSortDescriptor alloc] initWithKey:@"list.index" ascending:YES];
        NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByCompleted, sortByList, sortByIndex]];
    }
    else if (_currentList)
    {
        // Include only the items that are not completed from the current list
        NSPredicate *currentListItems = [NSPredicate predicateWithFormat:@"completed == %@ and list.name like %@",
                                         [NSNumber numberWithBool:_completedItems], _currentList.name];
        [fetchRequest setPredicate:currentListItems];

        // Sort the items by index
        NSSortDescriptor *sortByCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
        NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByCompleted, sortByIndex]];
    }
    else if (_currentDate > 0)
    {
        // Extract the year, month and day of the current date
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];

        // Create a date corresponding to midnight on the current day
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        NSDate *currentDay = [calendar dateFromComponents:dateComponents];

        NSDate *dateRange;
        switch (_currentDate)
        {
            case 1:
                dateRange = [currentDay dateByAddingTimeInterval:1*24*60*60];
                break;
                
            case 2:
                dateRange = [currentDay dateByAddingTimeInterval:2*24*60*60];
                break;

            case 3:
                dateRange = [currentDay dateByAddingTimeInterval:7*24*60*60];
                break;

            default:
                dateRange = [NSDate distantFuture];
                break;
        }

        // Include only the items that are not completed and have a due date within the selected range
        NSPredicate *allListItems = [NSPredicate predicateWithFormat:@"completed == %@ and dueDate <= %@",
                                     [NSNumber numberWithBool:_completedItems], dateRange];
        [fetchRequest setPredicate:allListItems];

        // Sort the items by date, then by index
        NSSortDescriptor *sortByCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
        NSSortDescriptor *sortByDate  = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
        NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByCompleted, sortByDate, sortByIndex]];
    }
    else if (_currentPlace)
    {
        // Include only the items that are not completed and associated with the current place
        NSPredicate *currentPlaceItems = [NSPredicate predicateWithFormat:@"completed == %@ and place.name like %@",
                                          [NSNumber numberWithBool:_completedItems], _currentPlace.name];
        [fetchRequest setPredicate:currentPlaceItems];

        // Sort the items by index
        NSSortDescriptor *sortByCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
        NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByCompleted, sortByIndex]];
    }
    else
    {
        // Include only the items that are not completed
        NSPredicate *allListItems = [NSPredicate predicateWithFormat:@"completed == %@", [NSNumber numberWithBool:_completedItems]];
        [fetchRequest setPredicate:allListItems];

        // Sort the items by list, then by index
        NSSortDescriptor *sortByCompleted = [[NSSortDescriptor alloc] initWithKey:@"completed" ascending:YES];
        NSSortDescriptor *sortByList  = [[NSSortDescriptor alloc] initWithKey:@"list.index" ascending:YES];
        NSSortDescriptor *sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortByCompleted, sortByList, sortByIndex]];
    }

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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    [self.itemTableView reloadData];
}

#pragma mark - View Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EditItemViewController *editViewController = [segue destinationViewController];
    editViewController.todoItem = sender;
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    [self saveContext];
    if (_currentList)
    {
        [self toDoListSelected:_currentList];
    }
    else
    {
        [self dateRangeSelected:_currentDate];
    }
    [self.itemTableView reloadData];
    [self didHideView:self.listTableView];
}

#pragma mark - Utility Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ItemTableViewCell class]])
    {
        // Fetch the appropriate to-do item
        ToDoItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

        // Specify the cell's delegate and to-do item
        [(ItemTableViewCell *)cell setDelegate:self];
        [(ItemTableViewCell *)cell setTodoItem:item];

//        // Create the fade in animation for the cell
//        [cell setAlpha:0.0f];
//        [UIView animateWithDuration:0.3f delay:0.1f*indexPath.row options:UIViewAnimationOptionCurveLinear
//                         animations:^{cell.alpha = 1.0f;}
//                         completion:^(BOOL finished){}];
    }
    else if ([cell isKindOfClass:[PlaceholderCell class]])
    {
        // Specify the cell's delegate and opacity
        [(PlaceholderCell *)cell itemLabel].text = @"";
        [(PlaceholderCell *)cell setDelegate:self];

        // Create the fade in animation for the cell
        [cell setAlpha:0.0f];
        [UIView animateWithDuration:0.6f delay:0.3f options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{cell.alpha = 1.0f;}
                         completion:^(BOOL finished){}];
    }
}

- (void)addItem
{
    // Create the new to-do item and add it to the top of the list
    ToDoItem *item = [self newItem];
    [self insertItem:item atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    // Refresh the table view
    [self.itemTableView reloadData];

    // Locate the cell that renders the newly added to-do item
    ItemTableViewCell *editingCell;
    for (ItemTableViewCell *cell in [self.itemTableView visibleCells])
    {
        if ([cell isKindOfClass:[ItemTableViewCell class]] && cell.todoItem == item)
        {
            editingCell = cell;
            break;
        }
    }

    // Enter editing mode
    [editingCell.itemLabel becomeFirstResponder];
}

- (ToDoItem *)newItem
{
    // Create a new to-do item
    ToDoItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];

    // Set the default properties and assign a unique identifier
    item.reference = [[NSUUID UUID] UUIDString];
    item.index = 0;
    item.text = @"";

    // Associate the item with the current list
    item.list = _currentList;

    return item;
}

- (void)createDefaultItems
{
    ToDoItem *pull = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    pull.index = 0;
    pull.reference = @"IntroItem1";
    pull.text = @"Pull down to add an item at the top";

    ToDoItem *pinch = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    pinch.index = 1;
    pinch.reference = @"IntroItem2";
    pinch.text = @"Pinch apart to insert between items";

    ToDoItem *right = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    right.index = 2;
    right.reference = @"IntroItem3";
    right.text = @"Swipe right to mark as completed";

    ToDoItem *left = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    left.index = 3;
    left.reference = @"IntroItem4";
    left.text = @"Swipe left to delete an item";

    ToDoItem *press = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    press.index = 4;
    press.reference = @"IntroItem5";
    press.text = @"Press and hold to move an item";

    ToDoItem *swipe = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.managedObjectContext];
    swipe.index = 5;
    swipe.reference = @"IntroItem6";
    swipe.text = @"Swipe from the edge to reveal lists";

    [self saveContext];
}

- (void)insertItem:(ToDoItem *)insertedItem atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = 0;
    for (ToDoItem *currentItem in [self.fetchedResultsController fetchedObjects])
    {
        if (index == indexPath.row) index++;

        if (currentItem == insertedItem)
        {
            currentItem.index = indexPath.row;
        }
        else
        {
            currentItem.index = index++;
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

- (void)reloadData
{
    [self.itemTableView reloadData];
}

- (void)showCompletedItems
{
    if (_completedItems)
    {
        self.navigationItem.rightBarButtonItem.title = @"\uf00c";
        _completedItems = NO;

        // Instantiate a new fetched results controller and reload the table data
        self.fetchedResultsController = nil;
        [self.itemTableView reloadData];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"\uf0e2";
        _completedItems = YES;

        // Instantiate a new fetched results controller and reload the table data
        self.fetchedResultsController = nil;
        [self.itemTableView reloadData];
    }
}

- (void)showEditListView
{
    [self performSegueWithIdentifier:@"segueToEditListView" sender:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
