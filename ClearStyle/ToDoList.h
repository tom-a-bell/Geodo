//
//  ToDoList.h
//  ClearStyle
//
//  Created by Tom Bell on 03/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;
@class ToDoItem;

@interface ToDoList : NSManagedObject

@property (nonatomic)         NSInteger index;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIColor  *color;
@property (nonatomic, retain) Place    *place;
@property (nonatomic, retain) NSSet    *items;

@end

@interface ToDoList (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ToDoItem *)value;
- (void)removeItemsObject:(ToDoItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
