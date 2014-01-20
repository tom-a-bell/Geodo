//
//  PlaceholderCell.m
//  Geodo
//
//  Created by Tom Bell on 15/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "PlaceholderCell.h"

@implementation PlaceholderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Specify placeholder text for the label
        self.itemLabel.placeholder = @"New item";

        // Hide the edit button
        self.editButton.hidden = YES;
    }

    return self;
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Call the delegate method
    [self.delegate cellDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Call the delegate method
    [self.delegate addItemFromPlaceholderCell:self];
}

@end
