//
//  DemoTableViewCell.m
//  Geodo
//
//  Created by Tom Bell on 18/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "DemoTableViewCell.h"

@implementation DemoTableViewCell
{
    UILabel *_symbolLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Add a symbol label for special user guide description items
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectNull];
        _symbolLabel.hidden = YES;
        _symbolLabel.textColor = [UIColor blackColor];
        _symbolLabel.textAlignment = NSTextAlignmentRight;
        _symbolLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_symbolLabel];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Specify the label frames
    self.itemLabel.frame  = CGRectMake(40, 0, self.bounds.size.width-40, self.bounds.size.height);

    // Hide the edit button
    self.editButton.hidden = YES;

    // Display the appropriate gesture symbol
    if (self.todoItem)
    {
        [self showSymbolLabel];
    }
}

- (void)setTodoItem:(ToDoItem *)todoItem
{
    [super setTodoItem:todoItem];

    // Display the appropriate gesture symbol
    [self showSymbolLabel];
}

// If the item is completed, change the symbol colour to match the default to-do item cell style
- (void)markAsCompleted:(BOOL)completed
{
    [super markAsCompleted:completed];

    _symbolLabel.textColor = completed? [UIColor whiteColor] : [UIColor blackColor];
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Disable editing of demo to-do items
    return NO;
}

#pragma mark - Utility Methods

// Utility method for creating custom symbol labels
- (void)showSymbolLabel
{
    NSInteger itemNumber = [[self.todoItem.reference substringFromIndex:(self.todoItem.reference.length - 1)] integerValue];

    switch (itemNumber)
    {
        case 1:
            _symbolLabel.text = @"\u21A7";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:18];
            _symbolLabel.frame = CGRectMake(15, 0, 18, self.bounds.size.height);
            break;

        case 2:
            _symbolLabel.text = @"\u2195";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:20];
            _symbolLabel.frame = CGRectMake(17, 0, 18, self.bounds.size.height-4);
            break;

        case 3:
            _symbolLabel.text = @"\u279C";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:18];
            _symbolLabel.frame = CGRectMake(15, 0, 18, self.bounds.size.height-4);
            break;

        case 4:
            _symbolLabel.text = @"\u279C";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:18];
            _symbolLabel.frame = CGRectMake(16, 2, 18, self.bounds.size.height-2);
            _symbolLabel.transform = CGAffineTransformMakeRotation(M_PI);
            break;

        case 5:
            _symbolLabel.text = @"\u21F5";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:24];
            _symbolLabel.frame = CGRectMake(16, 0, 16, self.bounds.size.height-8);
            IF_PRE_IOS7(
                        _symbolLabel.text = @"\u2195";
                        _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:20];
                        _symbolLabel.frame = CGRectMake(17, 0, 18, self.bounds.size.height-4);
            );
            break;

        case 6:
            _symbolLabel.text = @"\u21A6";
            _symbolLabel.font = [UIFont fontWithName:@"ArialUnicodeMS" size:18];
            _symbolLabel.frame = CGRectMake(15, 0, 17, self.bounds.size.height-3);
            break;

        default:
            break;
    }

    _symbolLabel.hidden = NO;
}

@end
