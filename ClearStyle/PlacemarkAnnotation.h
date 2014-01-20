//
//  PlacemarkAnnotation.h
//  ClearStyle
//
//  Created by Tom Bell on 09/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlacemarkAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) MKPlacemark *placemark;

- (id)initWithPlacemark:(id)placemark;
- (CLLocationCoordinate2D)coordinate;
- (NSString *)title;
- (NSString *)details;
- (NSString *)subtitle;

@end
