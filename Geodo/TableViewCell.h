//
//  TableViewCell.h
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TextField.h"

// A custom table view cell abstract class including an editable text field
@interface TableViewCell : UITableViewCell <UITextFieldDelegate>

// An editable text field
@property (nonatomic, strong, readonly) TextField *itemLabel;

// A button used to edit associated properties
@property (weak, nonatomic) UIButton *editButton;

@end
