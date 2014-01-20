//
//  AppDelegate.h
//  ClearStyle
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) LocationHandler *locationHandler;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
