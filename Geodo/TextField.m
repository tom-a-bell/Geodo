//
//  TextField.m
//  Geodo
//
//  Created by Tom Bell on 01/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "TextField.h"

@implementation TextField

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent long-press gestures when not in edit mode
    if (!self.editing && [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
        return;
    }

    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end
