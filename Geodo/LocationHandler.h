//
//  LocationHandler.h
//  Geodo
//
//  Created by Tom Bell on 11/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class ToDoItem;

@interface LocationHandler : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (LocationHandler *)sharedInstance;

- (void)stopMonitoringForItem:(ToDoItem *)item;

@end
