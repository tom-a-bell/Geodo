//
//  PlacemarkAnnotation.m
//  ClearStyle
//
//  Created by Tom Bell on 09/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

#import "PlacemarkAnnotation.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation PlacemarkAnnotation

- (id)initWithPlacemark:(id)placemark
{
    self = [super init];
    if (self)
    {
        _placemark = placemark;
    }
    return self;
}

#pragma mark - MKAnnotation Protocol Methods

- (CLLocationCoordinate2D)coordinate
{
    return self.placemark.location.coordinate;
}

- (NSString *)title
{
    if ([self.placemark.name length] > 0)
    {
        return self.placemark.name;
    }
    else if ([[self.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] firstObject])
    {
        return [[self.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] firstObject];
    }
    return ABCreateStringWithAddressDictionary(self.placemark.addressDictionary, NO);
}

- (NSString *)subtitle
{
    // Return nil to disable the subtitle field in annotation views
    return nil;

    // Return further details about the placemark
    return self.details;
}

- (NSString *)details
{
    if ([[self.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] count] > 1)
    {
        NSArray *addressLines = [self.placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
        NSString *address = addressLines[1];
        for (int i = 2; i < addressLines.count; i++)
        {
            address = [address stringByAppendingFormat:@", %@", addressLines[i]];
        }
        return address;
    }
    else if ([self.placemark.thoroughfare length] > 0)
    {
        return self.placemark.thoroughfare;
    }
    else if ([self.placemark.addressDictionary count] > 1)
    {
        return ABCreateStringWithAddressDictionary(self.placemark.addressDictionary, NO);
    }
    return nil;
}

@end
