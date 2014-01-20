//
//  Placemark.h
//  Geodo
//
//  Created by Tom Bell on 14/01/2014.
//  Copyright (c) 2014 Tom Bell. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Placemark : MKPlacemark

extern NSString * const kPlacemarkAddressNameKey;
extern NSString * const kPlacemarkAddressThoroughfareKey;
extern NSString * const kPlacemarkAddressSubThoroughfareKey;
extern NSString * const kPlacemarkAddressLocalityKey;
extern NSString * const kPlacemarkAddressSubLocalityKey;
extern NSString * const kPlacemarkAddressAdministrativeAreaKey;
extern NSString * const kPlacemarkAddressSubAdministrativeAreaKey;
extern NSString * const kPlacemarkAddressPostalCodeKey;
extern NSString * const kPlacemarkAddressCountryKey;
extern NSString * const kPlacemarkAddressCountryCodeKey;

@end
