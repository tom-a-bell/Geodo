//
//  EditItemViewController.m
//  ClearStyle
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "EditItemViewController.h"
#import "LocationViewController.h"
#import "ListViewController.h"
#import "ToDoList.h"

@implementation EditItemViewController
{
    // Store the change state of the due date
    BOOL _dateHasChanged;

    // Store the change state of the location
    BOOL _placeHasChanged;

    // Store the change state of the list
    BOOL _listHasChanged;
}

static NSInteger defaultAlarmHour = 9;
static NSInteger defaultAlarmMinute = 0;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the animation style for hiding/revealing cells
    self.reloadTableViewRowAnimation = UITableViewRowAnimationFade;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationFade;
    self.insertTableViewRowAnimation = UITableViewRowAnimationFade;

    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor darkTextColor], NSForegroundColorAttributeName,
                                    [UIColor darkTextColor], NSBackgroundColorAttributeName, nil];

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];);
    [self.navigationItem setHidesBackButton:YES animated:NO];

    // Populate the view properties
    self.itemDescription.text = self.todoItem.text;

    if (self.todoItem.dueDate)
    {
        [self.hasDate setOn:YES];
        [self.dueDate setDate:self.todoItem.dueDate];
        [self.currentDueDate setText:[NSDateFormatter localizedStringFromDate:self.todoItem.dueDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle]];
        [self cells:self.dueDatePicker setHidden:NO];
        [self reloadDataAnimated:NO];
    }
    else
    {
        // Specify the initial due date with the default alarm time
        self.dueDate.date = [self defaultDueDate];

        [self.hasDate setOn:NO];
        [self.currentDueDate setText:[NSDateFormatter localizedStringFromDate:self.dueDate.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle]];
        [self cells:self.dueDatePicker setHidden:YES];
        [self reloadDataAnimated:NO];
    }

    if (self.todoItem.place)
    {
        [self.hasLocation setOn:YES];
        [self.location setText:self.todoItem.place.name];
        [self cells:self.selectLocation setHidden:NO];
        [self reloadDataAnimated:NO];
    }
    else
    {
        [self.hasLocation setOn:NO];
        [self cells:self.selectLocation setHidden:YES];
        [self reloadDataAnimated:NO];
    }

    if (self.todoItem.list)
    {
        [self.list setText:self.todoItem.list.name];
    }

    if (self.todoItem.notes && ![self.todoItem.notes isEqualToString:@""])
    {
        self.notes.text = self.todoItem.notes;
        self.notes.textColor = [UIColor blackColor];
    }
    else
    {
        // Set the placeholder text in the notes text view
        self.notes.text = @"Notes";
        self.notes.textColor = [UIColor lightGrayColor];
    }

    // Set the due date, location and list states as unchanged
    _dateHasChanged = NO;
    _placeHasChanged = NO;
    _listHasChanged = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Update the view properties when returning from child views
    if (self.todoItem.place) [self.location setText:self.todoItem.place.name];
    if (self.todoItem.list) [self.list setText:self.todoItem.list.name];
}

- (IBAction)descriptionChanged:(id)sender
{
    self.todoItem.text = self.itemDescription.text;
}

- (IBAction)dueDateToggled:(id)sender
{
    _dateHasChanged = YES;
    [self cells:self.dueDatePicker setHidden:!self.hasDate.on];
    [self reloadDataAnimated:YES];
}

- (IBAction)locationToggled:(id)sender
{
    _placeHasChanged = YES;
    [self cells:self.selectLocation setHidden:!self.hasLocation.on];
    [self reloadDataAnimated:YES];
}

- (IBAction)dateChanged:(id)sender
{
    _dateHasChanged = YES;
    self.todoItem.dueDate = self.dueDate.date;
    self.currentDueDate.text = [NSDateFormatter localizedStringFromDate:self.dueDate.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close the keyboard on pressing enter
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UITextViewDelegate Protocol Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Notes"])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Notes";
        textView.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.todoItem.notes = self.notes.text;
    }
    
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Each typed character is passed in as the text parameter

    // Newline (return) characters trigger the end of editing
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];

        // Return NO so that the final newline character is not added
        return NO;
    }

    // For any other character, return YES so that it gets added to the view's text
    return YES;
}

#pragma mark - UITableViewDelegate Protocol Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] != 1)
    {
        [self.itemDescription resignFirstResponder];
    }
    if ([indexPath row] != 11)
    {
        [self.notes resignFirstResponder];
    }
}

#pragma mark - View Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set up the location view controller properties
    if ([segue.identifier isEqualToString:@"segueToLocationView"])
    {
        LocationViewController *viewController = [segue destinationViewController];

        // Specify the location
        viewController.place = self.todoItem.place;
    }

    // Set up the list view controller properties
    if ([segue.identifier isEqualToString:@"segueToSelectListView"])
    {
        ListViewController *viewController = [segue destinationViewController];

        // Specify the to-do item
        viewController.todoItem = self.todoItem;
    }

    // Update the to-do item properties before returning
    if ([segue.identifier isEqualToString:@"segueToListView"])
    {
        self.todoItem.text = self.itemDescription.text;
        self.todoItem.dueDate = self.hasDate.on ? self.dueDate.date : nil;
        self.todoItem.place = self.hasLocation.on ? self.todoItem.place : nil;
        self.todoItem.notes = ![self.notes.text isEqualToString:@"Notes"] ? self.notes.text : nil;

        // (Re-)schedule alarms associated with the item's due date
        if (_dateHasChanged || _placeHasChanged)
        {
            // Cancel any due date notifications associated with this item
            [self.todoItem cancelScheduledNotifications];

            // Only schedule notifications for items with no associated location
            if (self.todoItem.place == nil)
            {
                // Schedule a new notification for the specified due date and time
                [self.todoItem scheduleNotificationForDueDate];
            }
        }
    }
}

- (IBAction)saveLocation:(UIStoryboardSegue *)segue
{
    LocationViewController *viewController = [segue sourceViewController];

    // Retrieve the location
    self.todoItem.place = viewController.place;

    if (self.todoItem.place)
    {
        [self.location setText:self.todoItem.place.name];
    }
}

#pragma mark - Utility Methods

- (NSDate *)defaultDueDate
{
    // Extract the year, month and day of the current date
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];

    // Set the time to the default alarm time
    [dateComponents setHour:defaultAlarmHour];
    [dateComponents setMinute:defaultAlarmMinute];

    return [calendar dateFromComponents:dateComponents];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
