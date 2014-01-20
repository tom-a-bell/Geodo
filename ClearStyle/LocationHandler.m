//
//  LocationHandler.m
//  ClearStyle
//
//  Created by Tom Bell on 11/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "LocationHandler.h"
#import "ToDoItem.h"
#import "ToDoList.h"
#import "Place.h"

@implementation LocationHandler

+ (LocationHandler *)sharedInstance
{
    // Declare a static variable for the instance.
    static LocationHandler *instance = nil;
    static dispatch_once_t onceToken;

    // Use the dispatch_once macro to allocate the LocationHandler instance using GCD.
    // The token makes sure that the dispatch_once macro is executed only once.
    dispatch_once(&onceToken, ^{
        instance = [[LocationHandler alloc] init];
    });

    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // If location services are not restricted, instantiate the location manager
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
            [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)
        {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
        }
    }
    return self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    NSLog(@"Places currently being monitored:");
    for (CLRegion *region in self.locationManager.monitoredRegions)
    {
        Place *place = [self locationForRegion:region];
        if (place)
        {
            NSLog(@"%@", place.name);
        }
        else
        {
            NSLog(@"Error: No place found for region identifier %@", region.identifier);
        }
    }

}

#pragma mark - Core Date Object Retrieval Methods

- (Place *)locationForRegion:(CLRegion *)region
{
    if (!self.managedObjectContext)
    {
        return nil;
    }

    // Create a fetch request for places matching the region identifier
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reference like %@", region.identifier];
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortByDate]];

    NSError *error = nil;
    NSArray *places = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    if (places.count > 1)
    {
        NSLog(@"Location handler found multiple places for the geofence id %@", region.identifier);
    }

    // Return the first place found matching the region identifier (nil if none found)
    return [places firstObject];
}

- (NSSet *)itemsForLocation:(Place *)place
{
    return place.items;
}

#pragma mark - To-do Item Modification Methods

- (void)stopMonitoringForItem:(ToDoItem *)item
{
    // Return if there is no place associated with this item
    if (!item.place)
    {
        return;
    }

    // Retrieve all to-do items associated with the same place
    NSMutableSet *items = [NSMutableSet setWithSet:item.place.items];

    // Remove the current item from the set
    [items removeObject:item];

    // If there are no more items associated with the place, stop monitoring its location
    if (items.count == 0)
    {
        for (CLCircularRegion *region in item.place.location)
        {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    Place *place = [self locationForRegion:region];
    if (!place)
    {
        NSLog(@"Error: No place found for region identifier %@", region.identifier);
        return;
    }

    // Retrieve all to-do items associated with this place, sorted by due date
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES];
    NSArray *sortedItems = [[self itemsForLocation:place] sortedArrayUsingDescriptors:@[sortByDate]];

    // Create notifications for the associated to-do items
    for (ToDoItem *item in sortedItems)
    {
        // If the item has a due date, schedule the notification, otherwise present it now
        if (item.dueDate != nil)
        {
            [item scheduleNotificationForDueDate];
        }
        else
        {
            [item presentNotificationNow];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    Place *place = [self locationForRegion:region];
    if (!place)
    {
        NSLog(@"Error: No place found for region identifier %@", region.identifier);
        return;
    }

    // Cancel any scheduled notifications for the to-do items associated with this place
    for (ToDoItem *item in [self itemsForLocation:place])
    {
        [item cancelScheduledNotifications];
    }
}

@end
