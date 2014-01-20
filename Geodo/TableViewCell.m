//
//  TableViewCell.m
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TableViewCell.h"

@implementation TableViewCell
{
    CAGradientLayer *_gradientLayer;
    CAGradientLayer *_shadowLayer;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Remove the default blue highlight for selected cells
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // Set the background colour of the cell
        IF_PRE_IOS7(self.backgroundColor = [UIColor whiteColor];);
        IF_PRE_IOS7(self.contentView.backgroundColor = [UIColor whiteColor];);

        // Add an editable text label
        _itemLabel = [[TextField alloc] initWithFrame:CGRectNull];
        _itemLabel.textColor = [UIColor blackColor];
        _itemLabel.font = [UIFont systemFontOfSize:16];
        _itemLabel.backgroundColor = [UIColor clearColor];
        _itemLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _itemLabel.returnKeyType = UIReturnKeyDone;
        _itemLabel.delegate = self;
        [self addSubview:_itemLabel];

        // Add a standard edit button
        _editButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [_editButton addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_editButton];

        // Add a layer that overlays the cell adding a subtle gradient effect
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
                                  (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor],
                                  (id)[[UIColor clearColor] CGColor],
                                  (id)[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
        _gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        [self.layer addSublayer:_gradientLayer];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Specify the label and button frames
    _itemLabel.frame  = CGRectMake(15, 0, self.bounds.size.width - 55, self.bounds.size.height);
    _editButton.frame = CGRectMake(self.bounds.size.width - 30, self.bounds.size.height / 2 - 11, 22, 22);

    // Ensure the gradient layers occupy the full bounds of the cell
    _gradientLayer.frame = self.bounds;
    _shadowLayer.frame = self.bounds;
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close the keyboard on pressing enter
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Disable editing by default; subclasses can override this behaviour
    return NO;
}

// Action(s) to perform when the edit button is pushed; subclasses can override this behaviour
- (void)editItem:(id)sender
{
}

@end
