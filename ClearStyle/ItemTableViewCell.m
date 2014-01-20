//
//  ItemTableViewCell.m
//  ClearStyle
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "DateString.h"

@implementation ItemTableViewCell
{
    UIView *_background;

    UILabel *_tickLabel;
	UILabel *_crossLabel;
    UILabel *_dateLabel;

    CGPoint _originalCenter;

    CGRect _originalCellFrame;
    CGRect _originalTickFrame;
    CGRect _originalCrossFrame;

	BOOL _markCompleteOnDragRelease;
	BOOL _deleteOnDragRelease;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Add tick and cross action cue labels
        _tickLabel = [self createCueLabel];
        _tickLabel.text = @" \uf00c";
        _tickLabel.textAlignment = NSTextAlignmentLeft;

        _crossLabel = [self createCueLabel];
        _crossLabel.text = @"\uf00d   ";
        _crossLabel.textAlignment = NSTextAlignmentRight;

        [self addSubview:_tickLabel];
        [self addSubview:_crossLabel];

        // Add a view to hide the cue labels with the cell background colour
        _background = [[UIView alloc] initWithFrame:CGRectNull];
        _background.backgroundColor = [UIColor whiteColor];
        _background.alpha = 1.0f;
        [self addSubview:_background];

        // Add a label for the to-do item due date
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectNull];
        _dateLabel.textColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_dateLabel];

        // Bring the item label and the edit button to the front of the subview
        [self bringSubviewToFront:self.itemLabel];
        [self bringSubviewToFront:self.editButton];

        // Allow the cue labels to be drawn outside the superview bounds
        [self.contentView.superview setClipsToBounds:NO];

         // Add a pan gesture recognizer
        UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Specify the label frames
    _tickLabel.frame  = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _crossLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _background.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    // Rearrange the labels if the item has a due date
    if (self.todoItem && self.todoItem.dueDate)
    {
        self.itemLabel.frame = CGRectMake(15, 0, self.bounds.size.width - 55, self.bounds.size.height * 0.75);
        _dateLabel.frame = CGRectMake(15, self.bounds.size.height / 2, self.bounds.size.width - 55, self.bounds.size.height / 2);
    }
}

- (void)setTodoItem:(ToDoItem *)todoItem
{
    _todoItem = todoItem;

    // Use an attributed string for the item label
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:todoItem.text];

    // Set the label text and attributes
    [self.itemLabel setAttributedText:attributedText];

    // Set the due date text
    if (todoItem.dueDate)
    {
        _dateLabel.text = [DateString stringForDate:todoItem.dueDate];
    }
    else
    {
        _dateLabel.text = @"";
    }

    // Set the completed state of the cell
    [self markAsCompleted:todoItem.completed];
}

// If the item is completed, use white strikethrough text and a green background
- (void)markAsCompleted:(BOOL)completed
{
    if (completed)
    {
        [self setStrikethroughLabel:YES];
        [self.itemLabel setTextColor:[UIColor whiteColor]];
        [_tickLabel setText:@" \uf0e2"];
        [_tickLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        [_dateLabel setTextColor:[UIColor whiteColor]];
        [self.editButton setHidden:YES];
        [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
    }
    else
    {
        [self setStrikethroughLabel:NO];
        [self.itemLabel setTextColor:[UIColor blackColor]];
        [_tickLabel setText:@" \uf00c"];
        [_tickLabel setFont:[UIFont fontWithName:@"FontAwesome" size:24]];
        [_dateLabel setTextColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
        if ([self.todoItem.dueDate compare:[NSDate date]] == NSOrderedAscending)
        {
            [_dateLabel setTextColor:[UIColor redColor]];
        }

        [self.editButton setHidden:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (!_todoItem.completed)
    {
        [_background setBackgroundColor:backgroundColor];
    }
    else
    {
        [_background setBackgroundColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
    }
}

- (void)setStrikethroughLabel:(BOOL)enable
{
    // Use an attributed string for the item label
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.itemLabel.attributedText];

    if (enable)
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:NSStrikethroughStyleAttributeName];
        [attributedText addAttributes:attributes range:NSMakeRange(0, attributedText.length)];
    }
    else
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:NSStrikethroughStyleAttributeName];
        [attributedText addAttributes:attributes range:NSMakeRange(0, attributedText.length)];
    }

    [self.itemLabel setAttributedText:attributedText];
}

#pragma mark - Horizontal Pan Gesture Methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Check for gestures other than the pan gesture
    if ([gestureRecognizer class] != [UIPanGestureRecognizer class])
    {
        return NO;
    }

    CGPoint location = [gestureRecognizer locationInView:[self superview]];

    // Check that the gesture was not started at the left screen edge
    if (location.x < 25)
    {
        return NO;
    }

    location = [self convertPoint:self.frame.origin toView:self.superview.window];

    // Check that the table view has not been moved by the slide to reveal gesture
    if (location.x > 100)
    {
        return NO;
    }

    CGPoint translation = [gestureRecognizer translationInView:[self superview]];

    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y))
    {
        return YES;
    }

    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // Step 1
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // If the gesture has just started, record the current centre location and label frames
        _originalCenter = self.center;
        _originalCellFrame = self.frame;
        _originalTickFrame = _tickLabel.frame;
        _originalCrossFrame = _crossLabel.frame;
    }

    // Step 2
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // Translate the center horizontally
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);

        // Determine whether the item has been dragged far enough to the right to initiate a complete action
        _markCompleteOnDragRelease = self.frame.origin.x > self.frame.size.width / 4;

        // Determine whether the item has been dragged far enough to the left to initiate a delete action
        _deleteOnDragRelease = self.frame.origin.x < -self.frame.size.width / 4;

        // Fade in the contextual cues
        _tickLabel.alpha  = MAX(MIN(1.0f, +self.frame.origin.x / (self.frame.size.width / 12) - 0.2f), 0.0f);
        _crossLabel.alpha = MAX(MIN(1.0f, -self.frame.origin.x / (self.frame.size.width / 12) - 0.2f), 0.0f);

        // Update the locations of the cue labels
        CGRect tickLabelFrame  = _originalTickFrame;
        CGRect crossLabelFrame = _originalCrossFrame;
        tickLabelFrame.origin.x  -= self.frame.origin.x;
        crossLabelFrame.origin.x -= self.frame.origin.x;
        _tickLabel.frame  = tickLabelFrame;
        _crossLabel.frame = crossLabelFrame;

        // Indicate when the item has been pulled far enough to invoke the given action
        _tickLabel.backgroundColor = _markCompleteOnDragRelease ? [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0] : [UIColor clearColor];
        _crossLabel.backgroundColor = _deleteOnDragRelease ? [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0] : [UIColor clearColor];
        if (self.todoItem.completed && _markCompleteOnDragRelease) _tickLabel.backgroundColor = [UIColor grayColor];
    }

    // Step 3
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // If the item has been completed, notify the delegate
        if (_markCompleteOnDragRelease)
        {
            [self.delegate markAsCompleted:self.todoItem];
        }
        // If the item is to be deleted, notify the delegate
        else if (_deleteOnDragRelease)
        {
            [self.delegate deleteItem:self.todoItem];
        }
        // Otherwise, snap back to the original location
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = _originalCellFrame;

                _tickLabel.frame  = _originalTickFrame;
                _crossLabel.frame = _originalCrossFrame;

                // Fade out the contextual cues
                _tickLabel.alpha  = 0.0f;
                _crossLabel.alpha = 0.0f;
            }];
        }
    }
}

#pragma mark - UITextFieldDelegate Protocol Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Disable editing of completed to-do items
    return !self.todoItem.completed;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Call the delegate method
    [self.delegate cellDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Call the delegate method
    [self.delegate cellDidEndEditing:self];

    // Set the to-do item description when an edit is complete
    self.todoItem.text = textField.text;
}

#pragma mark - Utility Methods

// Utility method for creating contextual cues
- (UILabel *)createCueLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectNull];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"FontAwesome" size:24]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAlpha:0.0f];
    return label;
}

// Utility method to notify the delegate that the to-do item should be edited
- (void)editItem:(id)sender
{
    [self.delegate editToDoItem:self.todoItem];
}

@end
