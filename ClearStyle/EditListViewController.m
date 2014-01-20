//
//  ListPropertyViewController.m
//  ClearStyle
//
//  Created by Tom Bell on 14/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "EditListViewController.h"
#import "LocationViewController.h"

@implementation EditListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the navigation bar properties
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor darkTextColor], NSForegroundColorAttributeName,
                                    [UIColor darkTextColor], NSBackgroundColorAttributeName, nil];

    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    IF_IOS7_OR_GREATER(self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];);
    [self.navigationItem setHidesBackButton:YES animated:NO];

    // Populate the view properties
    self.name.text = self.todoList.name;

    for (UITableViewCell *cell in self.colors)
    {
        cell.tintColor = cell.textLabel.textColor;
        cell.accessoryType = [cell.textLabel.textColor isEqual:self.todoList.color] ?
            UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

    if (self.todoList.place)
    {
        [self.location setText:self.todoList.place.name];
    }
}

- (IBAction)nameChanged:(id)sender
{
    self.todoList.name = self.name.text;
}

- (IBAction)saveLocation:(UIStoryboardSegue *)segue
{
    LocationViewController *viewController = [segue sourceViewController];

    // Retrieve the location
    self.todoList.place = viewController.place;

    if (self.todoList.place)
    {
        [self.location setText:self.todoList.place.name];
    }
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close the keyboard on pressing enter
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UITableViewDelegate Protocol Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the list name is being edited, end editing when another row is selected
    if (indexPath.row != 1 && self.name.isEditing)
    {
        [self.name resignFirstResponder];
        return;
    }

    // Return if the row does not correspond to a colour option
    if (indexPath.row < 3 || indexPath.row > [tableView numberOfRowsInSection:indexPath.section] - 4)
    {
        return;
    }

    // Clear all checkmarks
    for (UITableViewCell *cell in self.colors)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Mark the selected row with a checkmark
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.todoList.color = cell.textLabel.textColor;
}

@end
