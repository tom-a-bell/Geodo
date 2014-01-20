//
//  GooglePlacesLoader.h
//  Geodo
//
//  Created by Tom Bell on 05/12/2013.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

typedef void (^SuccessHandler)(NSDictionary *responseDictionary);
typedef void (^ErrorHandler)(NSError *error);

@interface GooglePlacesLoader : NSObject

+ (GooglePlacesLoader *)sharedInstance;

- (void)loadPOIsForKeywords:(NSString *)keywords location:(CLLocation *)location radius:(NSInteger)radius
             successHandler:(SuccessHandler)handler errorHandler:(ErrorHandler)errorHandler;

@end
