//
//  AppDelegate.m
//  Geodo
//
//  Created by Tom Bell on 23/11/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "ItemTableViewController.h"
#import "ListTableViewController.h"

@implementation AppDelegate
{
    // Store the to-do items associated with local notifications as a LIFO stack
    NSMutableArray *_notificationItems;

    // Store the view controllers for the to-do item and to-do list tables
    ItemTableViewController *_itemTableViewController;
    ListTableViewController *_listTableViewController;
}

@synthesize locationHandler = _locationHandler;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;

        NavigationController *masterNavigationController = splitViewController.viewControllers[0];
        masterNavigationController.managedObjectContext = self.managedObjectContext;

        _itemTableViewController = (ItemTableViewController *)masterNavigationController.topViewController;
        _itemTableViewController.managedObjectContext = self.managedObjectContext;
    }
    else
    {
        NavigationController *navigationController = (NavigationController *)self.window.rootViewController;
        navigationController.managedObjectContext = self.managedObjectContext;

        _itemTableViewController = (ItemTableViewController *)navigationController.topViewController;
        _itemTableViewController.managedObjectContext = self.managedObjectContext;
    }

    // Instantiate the location handler
    _locationHandler = [[LocationHandler alloc] init];
    _locationHandler.managedObjectContext = self.managedObjectContext;

    // Instantiate the stack of notification items
    _notificationItems = [[NSMutableArray alloc] init];

    // Reset the badge count
    application.applicationIconBadgeNumber = 0;

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *itemText = [userInfo objectForKey:@"ItemDescription"];
    NSString *itemRef  = [userInfo objectForKey:@"ItemReference"];
    NSString *itemList = [userInfo objectForKey:@"ItemList"];

    // Retrieve the to-do item associated with this notification
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ToDoItem"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reference like %@", itemRef];
    [request setPredicate:predicate];

    NSError *error = nil;
    ToDoItem *item = [[self.managedObjectContext executeFetchRequest:request error:&error] firstObject];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    // Store the item for later action based on the user's response to the alert dialog
    [_notificationItems addObject:item];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:itemList message:itemText delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:NSLocalizedString(@"Completed", nil), nil];
    [alertView show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.

    // Reset the badge count
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data Stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;

    if (coordinator)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ToDoModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Geodo.sqlite"];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Utility Methods

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Remove the item associated with this notification from the list
    ToDoItem *item = [_notificationItems lastObject];
    [_notificationItems removeLastObject];

    if ([[alertView buttonTitleAtIndex:buttonIndex] localizedCompare:@"View Details"] == NSOrderedSame)
    {
        [_listTableViewController selectList:item.list];
        [_itemTableViewController editToDoItem:item];
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] localizedCompare:@"Completed"] == NSOrderedSame)
    {
        [_itemTableViewController markAsCompleted:item];
    }
}

- (ListTableViewController *)listTableViewController
{
    if (_itemTableViewController)
    {
        return (ListTableViewController *)_itemTableViewController.listTableView.delegate;
    }

    return nil;
}

//- (ItemTableViewController *)itemTableViewController
//{
//    UIViewController *controller = nil;
//
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//    {
//        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//        NavigationController *masterNavigationController = splitViewController.viewControllers[0];
//        controller = masterNavigationController.topViewController;
//    }
//    else
//    {
//        NavigationController *navigationController = (NavigationController *)self.window.rootViewController;
//        controller = navigationController.topViewController;
//    }
//
//    if ([controller isKindOfClass:[ItemTableViewController class]])
//    {
//        return (ItemTableViewController *)controller;
//    }
//
//    return nil;
//}

@end
