//
//  NavigationController.h
//  Geodo
//
//  Created by Tom Bell on 03/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationController : UINavigationController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
