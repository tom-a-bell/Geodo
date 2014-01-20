//
//  EditItemViewController.h
//  Geodo
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StaticDataTableViewController.h"
#import "ToDoItem.h"

@interface EditItemViewController : StaticDataTableViewController <UITextFieldDelegate, UITextViewDelegate>

// The to-do item that this view edits
@property (nonatomic) ToDoItem *todoItem;

@property (weak, nonatomic) IBOutlet UITextField *itemDescription;

@property (weak, nonatomic) IBOutlet UISwitch *hasDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDate;
@property (weak, nonatomic) IBOutlet UILabel *currentDueDate;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *dueDatePicker;

@property (weak, nonatomic) IBOutlet UISwitch *hasLocation;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *selectLocation;

@property (weak, nonatomic) IBOutlet UILabel *list;
@property (weak, nonatomic) IBOutlet UITextView *notes;

- (IBAction)descriptionChanged:(id)sender;
- (IBAction)dueDateToggled:(id)sender;
- (IBAction)locationToggled:(id)sender;
- (IBAction)dateChanged:(id)sender;

@end
