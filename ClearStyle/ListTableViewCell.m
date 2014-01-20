//
//  ListTableViewCell.m
//  ClearStyle
//
//  Created by Tom Bell on 30/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        // Specify text properties for the label
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];

        // Hide the text field and edit button
        self.itemLabel.hidden = YES;
        self.editButton.hidden = YES;

        _indicatorLabel = [[UILabel alloc] initWithFrame:CGRectNull];
        _indicatorLabel.text = @"";
        _indicatorLabel.textColor = [UIColor lightTextColor];
        _indicatorLabel.backgroundColor = [UIColor clearColor];
        _indicatorLabel.font = [UIFont fontWithName:@"FontAwesome" size:14];
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_indicatorLabel];

//        _indicatorSymbol = @"\u25c9";
//        _indicatorSymbol = @"\u25cf";
        _indicatorSymbol = @"\uf111";
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Specify the label frame
    self.textLabel.frame = CGRectMake(10, 0, self.bounds.size.width - 30, self.bounds.size.height);

    // Specify the indicator label frame
    _indicatorLabel.frame  = CGRectMake(self.bounds.size.width - 30, self.bounds.size.height / 2 - 15, 30, 30);
}

- (void)setIndicatorSymbol:(NSString *)indicatorSymbol
{
    _indicatorSymbol = indicatorSymbol;

    if (self.selected)
    {
        _indicatorLabel.text = indicatorSymbol;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Set the indicator label for the selected state
    [self setIndicatorState:selected];
}

- (void)setIndicatorState:(BOOL)enable
{
    _indicatorLabel.text = enable ? _indicatorSymbol : @"";
}

- (void)setTodoList:(ToDoList *)todoList
{
    _todoList = todoList;
    _dateRange = nil;
    _place = nil;

    // Set the label text
    self.textLabel.text = todoList.name;

    // Specify text properties for the label
    self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.textLabel.textColor = [UIColor whiteColor];

    // Specify the background and indicator label colours
    self.backgroundColor = todoList.color;
    IF_PRE_IOS7(self.contentView.backgroundColor = todoList.color;);
    self.indicatorLabel.textColor = [UIColor lightTextColor];

    // Specify the indicator symbol
    self.indicatorSymbol = @"\uf0ca";
}

- (void)setPlace:(Place *)place
{
    _place = place;
    _todoList = nil;
    _dateRange = nil;

    // Set the label text
    self.textLabel.text = place.name;

    // Specify text properties for the label
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = [UIColor darkGrayColor];

    // Specify the background and indicator label colours
    self.backgroundColor = [UIColor lightGrayColor];
    IF_PRE_IOS7(self.contentView.backgroundColor = [UIColor lightGrayColor];);
    self.indicatorLabel.textColor = [UIColor darkGrayColor];

    // Specify the indicator symbol
    self.indicatorSymbol = @"\uf124";
}

- (void)setDateRange:(NSString *)dateRange
{
    _dateRange = dateRange;
    _todoList = nil;
    _place = nil;

    // Set the label text
    self.textLabel.text = dateRange;

    // Specify text properties for the label
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.textColor = [UIColor lightTextColor];

    // Specify the background and indicator label colours
    self.backgroundColor = [UIColor darkGrayColor];
    IF_PRE_IOS7(self.contentView.backgroundColor = [UIColor darkGrayColor];);
    self.indicatorLabel.textColor = [UIColor lightTextColor];

    // Specify the indicator symbol
    self.indicatorSymbol = @"\uf017";
}

@end
