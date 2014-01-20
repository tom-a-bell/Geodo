//
//  Place.h
//  ClearStyle
//
//  Created by Tom Bell on 10/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class ToDoItem;
@class ToDoList;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSArray  *location;
@property (nonatomic, retain) NSDate   *created;
@property (nonatomic, retain) NSSet    *items;
@property (nonatomic, retain) NSSet    *lists;
@property (nonatomic) BOOL favourite;

@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ToDoItem *)value;
- (void)removeItemsObject:(ToDoItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addListsObject:(ToDoList *)value;
- (void)removeListsObject:(ToDoList *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;

@end
