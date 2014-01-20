//
//  ListPropertyViewController.h
//  Geodo
//
//  Created by Tom Bell on 14/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoList.h"

@interface EditListViewController : UITableViewController <UITextFieldDelegate>

// The to-do list that this view edits
@property (nonatomic) ToDoList *todoList;

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *colors;
@property (weak, nonatomic) IBOutlet UILabel *location;

- (IBAction)nameChanged:(id)sender;

@end
