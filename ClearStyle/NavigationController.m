//
//  NavigationController.m
//  ClearStyle
//
//  Created by Tom Bell on 03/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.visibleViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
